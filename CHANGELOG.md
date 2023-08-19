# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2023-08-19
### Added
- Added support for Sidekiq 7.
- Added support for request-specific context (`CurrentAttributes`). 
  See this [blog post](https://www.mikeperham.com/2022/07/29/sidekiq-and-request-specific-context/) for details.

## [1.0.0] - 2022-08-01

No changes, just publishing the release candidate as a final release.

## [0.99.0.rc] - 2022-07-18
### Added
- Logcraft::Sidekiq was extracted (and rewritten) from its predecessor: [Ezlog](https://github.com/emartech/ezlog).
