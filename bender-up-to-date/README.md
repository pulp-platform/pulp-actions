# Bender up-to-date

This action runs `bender script -n flist` and checks if all specified files exist in the repository. Useful as a sanity test in repositories that otherwise don't use bender.

## Action usage

Simply add the action to your desired upstream workflow. Optionally specify a bender version using `bender-version` (default: latest). We suggest creating a standalone workflow with appropriate trigger rules for this, for example:

```yaml
name: bender-up-to-date

on: [ push, pull_request, workflow_dispatch ]

jobs:
  bender-up-to-date:
    runs-on: ubuntu-latest
    steps:
      - name: Check Bender up-to-date
        uses: pulp-platform/pulp-actions/bender-up-to-date@v2
        with:
          bender-version: 0.27.1
```
