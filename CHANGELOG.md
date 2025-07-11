# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.5] - 2025-07-11

### Changed

-   **Theme Update:** The "basic" theme no longer uses blue for info text. It now uses the primary color (bright white) for a cleaner, more minimal look.

## [1.7.4] - 2025-07-11

### Fixed

-   **Restart Reliability:** The `stop` command now waits until the Ollama server process has fully terminated before exiting. This resolves a race condition in the `restart` command that could cause a "address already in use" error.

## [1.7.3] - 2025-07-11

### Changed

-   **Smarter Start Command:** The `start` command now checks if an Ollama server is already running. If so, it proceeds to warm up the model without trying to start a new server, preventing "address already in use" errors.

## [1.7.2] - 2025-07-11

### Changed

-   **Debug Mode:** The server log is now streamed directly in the current terminal window instead of opening a new one. The log streaming runs as a background job, allowing the user to see the log and the script's output simultaneously.

## [1.7.1] - 2025-07-10

### Fixed

-   **Debug Mode:** Fixed a bug where debug mode would try to start a second `ollama serve` instance, causing an "address already in use" error. It now correctly tails the log of the existing server process.
-   **Color Formatting:** Fixed a bug where ANSI color codes were not being interpreted correctly in the interactive wizard's menu prompt.

## [1.7.0] - 2025-07-10

### Added

-   **Debug Mode:** A `--debug` flag for the `start` and `restart` commands will now open the `ollama serve` log in a new terminal window for live monitoring.

## [1.6.0] - 2025-07-10

### Added

-   **Theming:** New `theme` command to switch between color palettes (basic, solarized, monokai). Theme choice is saved to `~/.ollamaX/config`.
-   **New Look:** Updated the visual design with a new default color scheme ("Terminal Basic") and professional, high-resolution emojis for better readability.

### Changed

-   **Smarter Wizard:** The interactive wizard no longer asks for a context size if the selected model already has one defined in its name (e.g., `model-ctx32k`).

## [1.5.1] - 2025-07-10

### Changed

-   The `install.sh` script now prints verbose output during manual installation but remains silent when run with a `--silent` flag (as used by the `update` command).

## [1.5.0] - 2025-07-10

### Added

-   New `version` command to display the current version of the script.
-   New `update` command to automatically fetch, install, and restart the script for a seamless, one-command update.

## [1.4.0] - 2025-07-10

### Added

-   Added color-coded output to the CLI for better readability and user experience. Success, error, warning, and informational messages are now highlighted.

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