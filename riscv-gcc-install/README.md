# RISC-V GCC install

This action downloads and installs a nightly build of the RISC-V GCC toolchain provided [here](https://github.com/riscv-collab/riscv-gnu-toolchain/releases). Not that as of writing, only Ubuntu LTS builds are provided.

## Action usage

Simply add the action to your desired upstream workflow. You can specify the `distro`, `nightly-date`, and `target`, which all have sensible defaults. Here is an example workflow using this action:

```yaml
name: riscv-gcc-install

on: [ push, pull_request, workflow_dispatch ]

jobs:
  riscv-gcc-install:
    runs-on: ubuntu-22.04
    steps:
      - name: RISC-V GCC install
        uses: pulp-platform/pulp-actions/riscv-gcc-install@v2.4.1 # update version as needed, not autoupdated
        with:
          distro: ubuntu-22.04
          nightly-date: '2023.03.14'
          target: riscv64-elf
```
