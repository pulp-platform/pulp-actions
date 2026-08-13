#!/usr/bin/env python3
#
# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Daniel Keller <dankeller@iis.ee.ethz.ch>

"""Exit non-zero when a slang diagnostic file contains errors.

Read straight from the diagnostics rather than from reviewdog's exit status:
reviewdog needs a token with check-write permission, which a pull request from
a fork does not get, so a gate built on it would pass silently exactly where a
public gate is worth the most.
"""

import json
import sys


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <diagnostics_json>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    try:
        with open(path, encoding="utf-8") as handle:
            diagnostics = json.load(handle)
    except FileNotFoundError:
        # slang always writes the file, so its absence means the run never
        # happened; failing here keeps a missing run from reading as success.
        print(f"error: no diagnostics at {path}; slang did not run", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as exc:
        print(f"error: {path} is not valid JSON: {exc}", file=sys.stderr)
        sys.exit(1)

    errors = [d for d in diagnostics if d.get("severity", "").lower() == "error"]
    if errors:
        print(f"slang reported {len(errors)} error(s):", file=sys.stderr)
        for diag in errors:
            location = diag.get("location", "")
            print(f"  {location}: {diag.get('message', '')}", file=sys.stderr)
        sys.exit(1)

    print(f"slang: no errors in {len(diagnostics)} diagnostic(s)")


if __name__ == "__main__":
    main()
