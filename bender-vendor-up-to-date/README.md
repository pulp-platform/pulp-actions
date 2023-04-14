# Bender vendor up-to-date

This action runs `bender vendor diff` and checks if all vendored dependencies are up-to-date, i.e. the state of the checked-in dependencies matches their upstream ref with the local patches applied.

## Action usage

Simply add the action to your desired upstream workflow. Optionally specify a bender version using `bender-version` (default: latest). We suggest creating a standalone workflow with appropriate trigger rules for this, for example:

```yaml
name: bender-vendor-up-to-date

on: [ push, pull_request, workflow_dispatch ]

jobs:
  bender-vendor-up-to-date:
    runs-on: ubuntu-latest
    steps:
      - name: Check bender vendor up-to-date
        uses: pulp-platform/pulp-actions/bender-vendor-up-to-date@v2
        with:
          bender-version: 0.27.1
```
