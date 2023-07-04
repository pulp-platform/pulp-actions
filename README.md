# Github Actions for PULP Platform

This is a collection of reusable Github Actions for repositories in the `pulp-platform` organization. PULP (Parallel Ultra-Low-Power) is an open-source multi-core computing platform developed in ongoing collaboration between ETH Zurich and the University of Bologna.

## How to use

There is a subdirectory for each action with a README providing setup instructions.

To use an action in your workflow, you must add its subdirectory to the repository path in the `uses` clause, e.g.:

```yaml
uses: pulp-platform/pulp-actions/gitlab-ci@v1
```

## Recommended third-party actions

We deliberately do not recreate or wrap functionality already provided by well-designed existing actions. Here is a list of third-party actions recommended for `pulp-platform` repositories:

* Linting:
    * C/C++: `DoozyX/clang-format-lint-action`
    * (System)Verilog: `chipsalliance/verible-linter-action`
    * Python: `py-actions/flake8`
    * Rust: `mbrobbel/rustfmt-check`
    * YAML: `ibiqlik/action-yamllint`

## License

The code in this repository is licensed under Apache 2.0 (see LICENSE).
