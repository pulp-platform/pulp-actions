# RISC-V GCC install

This action downloads and installs a nightly build of the RISC-V GCC toolchain provided [here](). Not that as of writing, only Ubuntu LTS builds are provided.

## Action usage

Simply add the action to your desired upstream workflow. You can specify the `distro`, `nightly-date`, and `target`, which all have sensible defaults. Here is an example workflow using this action:

```yaml
name: lint-license

on: [ push, pull_request, workflow_dispatch ]

jobs:
  lint-license:
    runs-on: ubuntu-latest
    steps:
      - name: lint license
        uses: pulp-platform/pulp-actions/lint-license@v2
        with:
          license: |
            Copyright (\d{4}(-\d{4})?\s)?(ETH Zurich and University of Bologna|lowRISC contributors).
            (Solderpad Hardware License, Version 0.51|Licensed under the Apache License, Version 2.0), see LICENSE for details.
            SPDX-License-Identifier: (SHL-0.51|Apache-2.0)
          exclude_paths: |
            sw/include/regs/*.h
            sw/include/geninfo.h
```
