# Bender Install

This action installs the specified or latest version of Bender.

## Action usage

Simply add the action to your desired upstream workflow. Indicate the desired version with the `version` argument, or omit it to install the latest version. If no version is specified and bender is already installed, the existing version will be used. For example:

```yaml
name: bender-install

on: [ push, pull_request, workflow_dispatch ]

jobs:
  bender-install:
    runs-on: ubuntu-latest
    steps:
      - name: bender install
        uses: pulp-platform/pulp-actions/bender-install@v2
        with:
          version: 0.27.1
```
