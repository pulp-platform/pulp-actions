# Detect RTL changes

This action checks whether the RTL sources a given top-level RTL module depends on have changed between two commits.

Internally, it uses `bender pickle --top <module>` to resolve the entire flat RTL a module depends on (including header files).
That output is hashed to produce a fingerprint of everything the module depends on.
Files not part of the Bender source graph (e.g. the scripts that drive compilation/simulation themselves) can additionally be watched.

This directory ships two things:
- `detect-rtl-changes.sh`: a CI-agnostic script that can be used in Gitlab CIs;
- `action.yml`: a GitHub Actions composite action wrapping the script.

## GitHub Actions usage

### Step-level skip

Gate a later step in the same job on the action's `rtl-changed` output:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - id: detect-rtl-changes
        uses: pulp-platform/pulp-actions/detect-rtl-changes@v2.6.0 # update version as needed, not autoupdated
        with:
          top: tb_my_module
          targets: test rtl
      - if: steps.detect-rtl-changes.outputs.rtl-changed == 'true'
        run: ./run_my_test.sh
```

### Job-level skip

Gate a whole job based on the action's `rtl-changed` output, computed in a previous job:

```yaml
jobs:
  detect-rtl-changes:
    runs-on: ubuntu-latest
    outputs:
      rtl-changed: ${{ steps.detect-rtl-changes.outputs.rtl-changed }}
    steps:
      - id: detect-rtl-changes
        uses: pulp-platform/pulp-actions/detect-rtl-changes@v2.6.0 # update version as needed, not autoupdated
        with:
          top: tb_my_module
          targets: test rtl

  test:
    needs: detect-rtl-changes
    if: needs.detect-rtl-changes.outputs.rtl-changed == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: ./run_my_test.sh
```

### Inputs

| Input | Description | Default |
| --- | --- | --- |
| `top` | Space-separated top-level module(s) (`bender pickle --top`). Omit to hash all sources resolved by Bender. | `''` |
| `targets` | Space-separated Bender target(s) (`bender pickle -t`). | `''` |
| `watch-paths` | Space-separated extra path(s) checked via plain `git diff`. | `''` |
| `compare-ref` | Git ref to diff against. | PR base commit / previous push commit / `HEAD^` |
| `bender-version` | Bender version to install. | latest |

## GitLab CI usage

GitLab CI can't consume a GitHub composite action directly, but a job can be gated by pulling and using the `detect-rtl-changes` script directly:

```yaml
before_script:
  - curl --proto '=https' --tlsv1.2 -sSf
      https://raw.githubusercontent.com/pulp-platform/pulp-actions/v2.6.0/detect-rtl-changes/detect-rtl-changes.sh
      -o ./detect-rtl-changes.sh
  - chmod +x ./detect-rtl-changes.sh

test:
  script:
    - ./detect-rtl-changes.sh -t test -t rtl -w .gitlab-ci.yml -- tb_my_module || exit 0
    - ./run_my_test.sh
```
