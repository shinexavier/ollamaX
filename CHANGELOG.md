# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2025-07-10

### Fixed

-   Fixed a bug in the interactive wizard where the "Clean Models" menu was not correctly processing user input.

## [1.2.1] - 2025-07-10

### Added

-   `uninstall.sh` script to remove the `ollamaX` executable from `/usr/local/bin`.

### Changed

-   Clarified the "Clean Models" option in the interactive wizard to read "Remove ALL models (configs and models)" for better user understanding.

## [1.2.0] - 2025-07-10

### Added

-   New `clean` command to remove models.
    -   `clean configs`: Removes only the model configurations created by ollamaX (those with a `-ctx...k` suffix).
    -   `clean all`: Removes all Ollama models from the system after a confirmation prompt.

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