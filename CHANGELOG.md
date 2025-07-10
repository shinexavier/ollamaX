# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-07-10

### Changed

-   The `start` command now checks if a model with the specified context size already exists. If it does, it reuses the existing model instead of creating a new one, preventing duplicate models.

## [1.0.0] - 2025-07-10

### Added

-   Initial release of OllamaX.
-   Interactive wizard for guided model management.
-   CLI commands: `start`, `stop`, `restart`, `list`, `switch`.
-   Placeholder for `recommend-ctx` command.
-   `install.sh` script for easy installation on macOS.
-   `README.md` with usage instructions.
-   `CHANGELOG.md` to track project history.