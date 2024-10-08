# Integrate

This action integrates the triggering IP into a dependent and checks the dependent's CI.

Internally, it clones the dependent repo, patches the `Bender.lock` to point to the version of the IP that triggered the action, pushes to the dependent repo, and polls the dependent's workflows.

> :warning: **Loop hazard**. Be careful not to create cyclic trigger jobs, otherwise the servers might crash.

## Preparation

You need to set up an access token for this action to push and poll the dependent repo.

1. Create access token: On GitHub, naviate to your profile, then *Settings* -> *Developer settings* -> *Personal access tokens* -> *Fine-grained tokens* -> *Generate new token* -> Select the desired dependent repo and the necessary permissions (R/W access to actions, code, commit statuses, deployments).

2. Store access token: Navigate to your IP's repo, *Settings* -> *Secrets and variables* -> *Actions* -> *New repository secret*. Paste the access token from the previous step.

Furthermore, this action (currently) assumes that the dependent uses [Bender](https://github.com/pulp-platform/bender) for dependency management and that there is a `Bender.lock` file in the dependent's root with a reference to the triggering IP.

## Action usage

Once this is done, you can add the action to your desired upstream workflow. We suggest creating a standalone workflow with appropriate trigger rules for this, for example:

```yaml
name: integration

on: [ push, pull_request, workflow_dispatch ]

jobs:
  cheshire-integration:
    runs-on: ubuntu-latest
    timeout-minutes: 200
    # Skip on forks due to missing secrets.
    if: github.repository == 'pulp-platform/cva6' && (github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository)
    steps:
      - name: Integrate into cheshire
        uses: pulp-platform/pulp-actions/integrate@v2.4.1 # update version as needed, not autoupdated
        with:
          ip-name: cva6
          org: pulp-platform
          repo: cheshire
          base-ref: cva6/pulp-v1.0.0
          token: ${{ secrets.CHESHIRE_TOKEN }}
          lifetime: 14
```
