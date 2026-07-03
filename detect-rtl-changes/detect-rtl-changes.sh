#!/usr/bin/env bash
#
# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author: Luca Colagrande <colluca@iis.ee.ethz.ch>
#
# Check whether the sources a CI job actually depends on changed.
#
# Background
# ----------
# Hand-maintained `changes:`/`paths:` lists (one per CI job, listing every
# source file a testbench/module transitively depends on) are error-prone:
# it is easy to forget a dependency, and the list silently goes stale as the
# RTL evolves. See https://github.com/pulp-platform/axi/issues/432.
#
# This script replaces those lists with a content hash of the *actual*
# dependency closure, computed by Bender + slang instead of by hand:
#
#   bender pickle --top <TOP> [-t <TARGET>]...
#
# statically elaborates the design from the given top-level module(s) and
# emits only the files reachable from it (trimming away unrelated sources),
# with header/include files inlined via `export_include_dirs`. Hashing that
# output gives a fingerprint of exactly what the job's outcome can depend on.
# The fingerprint is compared between the working tree and a base git ref; if
# they match, the job's real work can be skipped.
#
# Any file that is not part of the Bender source graph (e.g. the scripts that
# drive compilation/simulation themselves) can additionally be watched with
# `-w/--watch`, which falls back to a plain `git diff` check.
#
# Usage
# -----
#   detect-rtl-changes.sh [-c REF] [-t TARGET]... [-w PATH]... [-- TOP...]
#
#   -c, --compare-ref REF   Git ref to diff against.
#                           (default: origin/$CI_DEFAULT_BRANCH, or origin/master)
#   -t, --target TARGET     Bender target to include (repeatable). Forwarded
#                           verbatim to `bender pickle -t TARGET`.
#   -w, --watch PATH        Extra path to check for plain (non-Bender-tracked)
#                           changes, e.g. a build/simulation script (repeatable).
#   TOP...                  Top-level module(s) to trim the source graph to.
#                           If omitted, the full (untrimmed) pickle is hashed,
#                           i.e. "did anything reachable by Bender change".
#
# Exit status
# -----------
#   0  the job should run (sources changed, or the check could not be
#      performed conclusively -- this script fails open, never silently
#      hiding a real change)
#   1  confirmed unchanged: the job can be safely skipped
#
# Typical use in a GitLab CI job's `script:`:
#
#   detect-rtl-changes.sh -t test -t rtl -- tb_$TEST_MODULE || exit 0
#
# For GitHub Actions, use the `detect-rtl-changes` action in this repository,
# which wraps this script and exposes a `changed` (true/false) step output
# instead of an exit code, since GitHub Actions can only condition steps and
# jobs on string outputs, not on another step's exit code.
#
# Reusability
# -----------
# This script has no repository-specific logic; it only assumes a
# Bender-managed package. It can be dropped into (or curled by) any
# Bender-based repository as-is.

set -uo pipefail

compare_ref="origin/${CI_DEFAULT_BRANCH:-master}"
targets=()
watch_paths=()

while [ $# -gt 0 ]; do
    case "$1" in
        -c|--compare-ref)
            compare_ref="$2"; shift 2 ;;
        -t|--target)
            targets+=("$2"); shift 2 ;;
        -w|--watch)
            watch_paths+=("$2"); shift 2 ;;
        --)
            shift; break ;;
        -h|--help)
            sed -n '2,64p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)
            echo "detect-rtl-changes: unknown option '$1', running job to be safe" >&2
            exit 0 ;;
        *)
            break ;;
    esac
done
tops=("$@")

target_args=()
for t in "${targets[@]}"; do
    target_args+=(-t "$t")
done

top_args=()
if [ ${#tops[@]} -gt 0 ]; then
    top_args=(--top "${tops[@]}")
fi

run_because() {
    echo "detect-rtl-changes: $1, running job" >&2
    exit 0
}

command -v bender >/dev/null 2>&1 || run_because "bender not found"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || run_because "not a git repository"

# Resolve the base ref locally, fetching it if necessary (CI checkouts are
# often shallow and may not have it yet).
if ! git rev-parse --verify --quiet "$compare_ref" >/dev/null; then
    remote="${compare_ref%%/*}"
    branch="${compare_ref#*/}"
    git fetch --quiet --depth=1 "$remote" "$branch" 2>/dev/null || true
fi
if ! base_sha=$(git rev-parse --verify --quiet "$compare_ref"); then
    run_because "could not resolve compare ref '$compare_ref'"
fi

# Plain-diff watch paths (files outside the Bender source graph).
if [ ${#watch_paths[@]} -gt 0 ]; then
    if ! git diff --quiet "$base_sha" -- "${watch_paths[@]}" 2>/dev/null; then
        run_because "watched path(s) changed (${watch_paths[*]})"
    fi
fi

pickle_hash() {
    bender -d "$1" pickle "${target_args[@]}" "${top_args[@]}" --no-progress 2>/dev/null \
        | sha256sum | cut -d' ' -f1
}

head_hash=$(pickle_hash .)
[ -n "$head_hash" ] || run_because "failed to pickle current sources"

worktree=$(mktemp -d)
cleanup() { git worktree remove --force "$worktree" >/dev/null 2>&1; rm -rf "$worktree"; }
trap cleanup EXIT

if ! git worktree add --detach --quiet "$worktree" "$base_sha" >/dev/null 2>&1; then
    run_because "could not check out '$compare_ref' into a worktree"
fi
# Reuse already-cloned dependencies instead of re-fetching them.
[ -d .bender ] && ln -s "$(pwd)/.bender" "$worktree/.bender"

base_hash=$(pickle_hash "$worktree")
[ -n "$base_hash" ] || run_because "failed to pickle sources at '$compare_ref'"

if [ "$head_hash" = "$base_hash" ]; then
    echo "detect-rtl-changes: no sources reachable from '${tops[*]:-<all>}' changed vs $compare_ref, skipping" >&2
    exit 1
fi

echo "detect-rtl-changes: sources reachable from '${tops[*]:-<all>}' changed vs $compare_ref, running job" >&2
exit 0
