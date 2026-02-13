# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project (post v2.1.0) adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

## 2.4.4 - 2026-05-21
### Fixed
- `bender-up-to-date`: Fix compatibility with bender v0.30.0+

## 2.4.3 - 2025-05-21
### Fixed
- Work around pip caching without `requirements.txt`

## 2.4.2 - 2024-09-11
### Added
- Add recommendation of `diff-porcelain` to README.md
- Add `pip` cache

### Changed
- Update `checkout` and `setup-python` subactions
- Update examples in action READMEs with newer versions and notice regarding updates

## 2.4.1 - 2024-07-05
### Fixed
- Ensure patches argument is optional in `lint-license`

## 2.4.0 - 2024-06-17
### Fixed
- Fix pagination issues in `gitlab-ci` through direct queries
- Improve error handling in `gitlab-ci`

## 2.3.0 - 2024-04-18
### Fixed
- Print API error responses for `gitlab-ci`
- Fail `integrate` action on failed dependent run

## 2.2.0 - 2024-02-22
### Added
- Add `integrate` action.

## 2.1.0 - 2023-07-11
### Added
- Add recommended YAML linter to `README.md`
- Add patching feature to `lint-license`

### Fixed
- Fix explanation in `gitlab-ci` README.

## 2 - 2023-04-14
### Added
- Add `install-bender` action.
- Add `bender-up-to-date` action.
- Add `lint-license` action.
- Add `bender-vendor-up-to-date` action.
- Add `riscv-gcc-install` action.
- Add info to `gitlab-ci` README.

### Fixed
- Fix indentation in `lint-license` README.
- Fix `lint-license` tool path.

## 1 - 2023-02-22
### Added
- Add `gitlab-ci` action.
