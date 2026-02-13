#!/usr/bin/env bash
#
# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>
# Riccardo Tedeschi <riccardo.tedeschi6@unibo.it>

set -e

if ! [[ $(bender --version 2>/dev/null) =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    echo "Error: Could not determine bender version. Is bender installed?" >&2
    exit 1
fi
current_version="${BASH_REMATCH[1]}"

# Capture the output AND check the exit code simultaneously.
# If Bender >= 0.29.0 detects missing files, it will exit with an error code > 0,
# and this block will catch it and exit immediately.
if ! BENDER_OUTPUT=$(bender script --no-deps flist); then
    exit 1
elif  printf '%s\n' "0.29.0" "$current_version" | sort -C -V; then
    # If we reach here, Bender >= 0.29.0 succeeded (all files exist).
    exit 0
fi

# If we reach here Bender < 0.29.0 succeeded (but might silently have missing files).
# We run the manual check to catch any missing files for older versions.
RESULT=0

# `|| true` prevents grep from crashing the script if it filters out all lines
while IFS= read -r FILE; do
    [ -z "$FILE" ] && continue

    if [ ! -f "$FILE" ]; then
        printf "bender-up-to-date: %s not found.\n" "$FILE"
        RESULT=1
    fi
done < <(printf "%s\n" "$BENDER_OUTPUT" | grep -v -e "^+" || true)

exit "$RESULT"
