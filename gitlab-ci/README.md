# Gitlab CI

This action mirrors a repository to a Gitlab remote, then polls for a CI pipeline and checks its completion status. The action passes if the mirror push succeeds, a pipeline is spawned, and that pipeline succeeds within a configurable timeout period.

## Preparation

First, create a Gitlab mirror repo and grant your Github upstream repo developer access to it:

1. Create a *blank target repo* on your Gitlab instance. For PULP members, use the `github-mirror` group, preserve the upstream repo name, and disable unnecessary Gitlab features in *Settings* → *General*.

2. Obtain a *project access token* to the Gitlab mirror. In *Settings* → *Access Tokens*, create a token called `github-ci` with role *Developer*, a reasonable expiry date, and all available scopes. After generation, copy the token from the top hidden text field to a temporary location; it will become inaccessible once you leave the page.

3. Add the project access token as a *secret* to your Github upstream repository. Go to *Settings* → *Secrets and variables* → *Actions* and add the token as a new repository secret called `GITLAB_TOKEN`. Again, the secret will become write-only once you leave the page.

## Action usage

Once this is done, you can add the action to your desired upstream workflow. We suggest creating a standalone workflow with appropriate trigger rules for this, for example:

```yaml
name: gitlab-ci

on: [ push, pull_request, workflow_dispatch ]

jobs:
  gitlab-ci:
    runs-on: ubuntu-latest
    steps:
      - name: Check Gitlab CI
        uses: pulp-platform/pulp-actions/gitlab-ci@v2
        # Skip on forks or pull requests from forks due to missing secrets.
        if: github.repository == 'pulp-platform/cheshire' && (github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository)
        with:
          domain: iis-git.ee.ethz.ch
          repo: github-mirror/cheshire
          token: ${{ secrets.GITLAB_TOKEN }}
```

Optional inputs controlling the Gitlab API version and timeouts are available; see `action.yml`.

Be sure to add a `.gitlab-ci.yml` to your repo; otherwise, the action will time out waiting for a pipeline to spawn on new commits, resulting in failure.
