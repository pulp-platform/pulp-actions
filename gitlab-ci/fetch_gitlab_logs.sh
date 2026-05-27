#!/usr/bin/env bash
# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE.APACHE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Fetch failed-job traces from the mirrored GitLab pipeline and surface them
# in the GitHub Actions console. Intended to run in a GitHub workflow step
# gated on `if: failure()` after the pulp-actions gitlab-ci check. Always
# exits 0 — the original gitlab-ci step is the one that fails the workflow;
# this script is purely informational.
#
# Required environment:
#   GITLAB_TOKEN   Token with read_api scope (same token used by the mirror).
#   GITLAB_DOMAIN  e.g. iis-git.ee.ethz.ch
#   GITLAB_REPO    e.g. github-mirror/<your-repo>
#   COMMIT_SHA     GitHub commit SHA mirrored to GitLab.
#   OUT_DIR        Output directory (created if missing).
#   API_VERSION    GitLab API version (defaults to v4).

set -u
set -o pipefail

: "${GITLAB_TOKEN:?GITLAB_TOKEN is required}"
: "${GITLAB_DOMAIN:?GITLAB_DOMAIN is required}"
: "${GITLAB_REPO:?GITLAB_REPO is required}"
: "${COMMIT_SHA:?COMMIT_SHA is required}"
: "${OUT_DIR:=gitlab-logs}"
: "${API_VERSION:=v4}"

mkdir -p "$OUT_DIR"

API="https://${GITLAB_DOMAIN}/api/${API_VERSION}"
PROJECT_ID="${GITLAB_REPO//\//%2F}"

# Pass the token via a 0600 curl config file rather than on the command line,
# so it does not appear in argv (visible to other processes via `ps`).
CURL_CONFIG=$(mktemp)
trap 'rm -f "$CURL_CONFIG"' EXIT
chmod 600 "$CURL_CONFIG"
printf 'header = "PRIVATE-TOKEN: %s"\n' "$GITLAB_TOKEN" > "$CURL_CONFIG"
CURL=(curl -fsSL --retry 3 --retry-delay 5 -K "$CURL_CONFIG")

sanitize() {
  # Replace characters that are awkward in filenames.
  echo "$1" | tr '/ :' '___'
}

# --- 1. Find the newest pipeline for this commit ---
PIPELINE_JSON=""
for attempt in 1 2 3 4 5; do
  if PIPELINE_JSON=$("${CURL[@]}" \
      "${API}/projects/${PROJECT_ID}/pipelines?sha=${COMMIT_SHA}&order_by=id&sort=desc&per_page=1") \
     && [ "$(echo "$PIPELINE_JSON" | jq 'length')" -gt 0 ]; then
    break
  fi
  echo "::warning::No GitLab pipeline found for ${COMMIT_SHA} yet (attempt ${attempt}/5), retrying in 10s…" >&2
  PIPELINE_JSON=""
  sleep 10
done

if [ -z "$PIPELINE_JSON" ] || [ "$(echo "$PIPELINE_JSON" | jq 'length')" -eq 0 ]; then
  echo "::warning::Gave up looking for a GitLab pipeline matching ${COMMIT_SHA}. Not fetching logs."
  exit 0
fi

PIPELINE_ID=$(echo "$PIPELINE_JSON" | jq -r '.[0].id')
PIPELINE_URL=$(echo "$PIPELINE_JSON" | jq -r '.[0].web_url')
echo "Inspecting GitLab pipeline ${PIPELINE_ID}: ${PIPELINE_URL}"

# --- 2. Paginate through jobs ---
JOBS_JSON="[]"
page=1
while :; do
  PAGE_JSON=$("${CURL[@]}" \
    "${API}/projects/${PROJECT_ID}/pipelines/${PIPELINE_ID}/jobs?per_page=100&page=${page}") || {
    echo "::warning::Failed to fetch jobs page ${page}; stopping pagination." >&2
    break
  }
  count=$(echo "$PAGE_JSON" | jq 'length')
  [ "$count" -eq 0 ] && break
  JOBS_JSON=$(jq -s '.[0] + .[1]' <(echo "$JOBS_JSON") <(echo "$PAGE_JSON"))
  [ "$count" -lt 100 ] && break
  page=$((page + 1))
done

# --- 3. For each failed job: fetch its trace ---
FAILED_COUNT=0
while IFS=$'\t' read -r job_id job_name job_stage; do
  [ -z "$job_id" ] && continue
  FAILED_COUNT=$((FAILED_COUNT + 1))
  # Suffix with the (unique) job id so retried jobs or jobs whose stage+name
  # sanitize to the same string don't overwrite each other's trace.
  slug="$(sanitize "$job_stage")__$(sanitize "$job_name")__${job_id}"
  trace_path="${OUT_DIR}/${slug}.trace"

  if ! err=$("${CURL[@]}" "${API}/projects/${PROJECT_ID}/jobs/${job_id}/trace" \
       -o "$trace_path" 2>&1); then
    echo "::warning::Could not fetch trace for job ${job_id} (${job_name}): ${err}" >&2
    echo "(trace unavailable)" > "$trace_path"
  fi

  echo "Trace: ${trace_path} (job=${job_name}, stage=${job_stage})"
done < <(echo "$JOBS_JSON" | jq -r '.[] | select(.status == "failed") | [.id, .name, .stage] | @tsv')

echo "Fetched ${FAILED_COUNT} failed job(s) from pipeline ${PIPELINE_URL}"
exit 0
