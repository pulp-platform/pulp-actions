# Lint License

This action installs and runs lowRISC's [license linter](https://github.com/lowRISC/misc-linters/tree/master/licence-checker), which checks all source files in a repository except specified paths for a license header. The header may be a regular expression.

## Action usage

Simply add the action to your desired upstream workflow. Indicate the license header with the `license` argument, and whether this is a regex with `match_regex` (defaults to true). You can optionally specify:

* `exclude_paths`: path expressions to exclude
* `linters_revison`: the revision of `lowRISC/misc-linters` to use
* `matcher`: an alternative matcher used to report violations

Here is an example workflow using this action:

```yaml
name: lint-license

on: [ push, pull_request, workflow_dispatch ]

jobs:
  lint-license:
    runs-on: ubuntu-latest
    steps:
      - name: lint license
        uses: pulp-platform/pulp-actions/lint-license@v2.4.1 # update version as needed, not autoupdated
        with:
          license: |
            Copyright (\d{4}(-\d{4})?\s)?(ETH Zurich and University of Bologna|lowRISC contributors).
            (Solderpad Hardware License, Version 0.51|Licensed under the Apache License, Version 2.0), see LICENSE for details.
            SPDX-License-Identifier: (SHL-0.51|Apache-2.0)
          exclude_paths: |
            sw/include/regs/*.h
            sw/include/geninfo.h
```
