# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-07-10

### Added

-   The `list` command now indicates the currently running model with a `(running)` marker.
-   New `unload` command to remove the currently loaded model from memory without stopping the server. This now uses a more reliable method and verifies that the model was unloaded.

### Fixed

-   Fixed a bug in the `clean configs` command where it failed to identify models with tags (e.g., `:latest`) appended after the context size.
-   Fixed a bug in the interactive wizard where the "Clean Models" menu was not correctly processing user input.

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