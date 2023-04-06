# Install Bender

This action installs the specified or latest version of Bender.

## Action usage

Simply add the action to your desired upstream workflow. Indicate the desired version with the `version` argument, or omit it to install the latest version. For example:

```yaml
name: install-bender

on: [ push, pull_request, workflow_dispatch ]

jobs:
  install-bender:
    runs-on: ubuntu-latest
    steps:
      - name: Install Bender
        uses: pulp-platform/pulp-actions/install-bender@v2
        with:
          version: 0.27.1
```
