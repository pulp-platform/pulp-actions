# Slang

This action builds a project with [slang](https://github.com/MikePopoloski/slang) and reports errors and warnings via [reviewdog](https://github.com/reviewdog/reviewdog).

## Action usage

Simply add the action to your desired upstream workflow. Pass `secrets.GITHUB_TOKEN` as the `token` argument and specify the [slang flags](https://sv-lang.com/command-line-ref.html) with `slang-flags` (at minimum a file list). You can optionally specify:

* `reviewdog-reporter`: the reviewdog reporter to use (defaults to `github-check`)

Here is an example workflow using this action:

```yaml
name: Slang lint

on:
  push:
  pull_request:
  workflow_dispatch:

jobs:
  slang:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      checks: write
      pull-requests: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Install bender
        uses: pulp-platform/pulp-actions/bender-install@v2.5.0 # update version as needed, not autoupdated

      - name: Generate file list
        shell: bash
        run: bender script flist-plus -t lint > sources.flist

      - name: Run slang
        uses: pulp-platform/pulp-actions/slang@v2.5.0 # update version as needed, not autoupdated
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          slang-flags: '-f sources.flist --top my_top -Wextra -Wno-width-trunc'
```
