#!/usr/bin/env python3
"""Run slang on a file list via pyslang's Driver API and emit a JSON diagnostic file."""

import sys

from pyslang import CommandLineOptions, Driver


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <flags>", file=sys.stderr)
        sys.exit(1)

    flags, output_json = sys.argv[1], sys.argv[2]

    driver = Driver()
    driver.addStandardArgs()

    args = (
        f"{sys.argv[0]}"
        f"{flags}"
        f" --error-limit 0"
        f" --diag-json {output_json}"
    )
    if not driver.parseCommandLine(args, CommandLineOptions()):
        sys.exit(1)

    if not driver.processOptions():
        sys.exit(1)

    driver.parseAllSources()
    driver.runFullCompilation()
    # Exit 0 regardless of compile errors so the CI step continues
    # and reviewdog can annotate the diagnostics.


if __name__ == "__main__":
    main()
