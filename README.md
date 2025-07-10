# OllamaX - A CLI Wizard for Ollama

OllamaX is a simple, user-friendly command-line interface (CLI) wrapper for managing [Ollama](https://ollama.ai/) models on macOS. It provides an interactive wizard to help you start, stop, and switch between models without having to remember all the `ollama` commands.

It's designed for developers who want a more streamlined workflow when working with multiple local LLMs.

## Features

- **Interactive Wizard**: Run `ollamaX` without any arguments to launch a step-by-step wizard.
- **Model Management**: Easily start, stop, restart, and switch between your downloaded Ollama models.
- **Context Size Configuration**: Set a custom context size (`num_ctx`) when starting a model.
- **Standard CLI Interface**: Can also be used with standard command-line arguments for scripting and automation.
- **Simple Installation**: A straightforward installation script to get you up and running quickly.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd ollamaX
    ```

2.  **Run the installation script:**
    This will copy the `ollamaX` command to `/usr/local/bin` and make it executable. You will be prompted for your password as it requires `sudo`.

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Start using OllamaX!**
    You can now run `ollamaX` from anywhere in your terminal.

    ```bash
    ollamaX
    ```

## Usage

### Interactive Wizard Mode

For the easiest experience, just run the command by itself:

```bash
ollamaX
```

This will launch a menu where you can choose what you want to do. The wizard will guide you through selecting a model and configuring options.

### Direct Command Mode

You can also use it like a standard CLI tool, which is useful for scripting.

**Syntax:** `ollamaX <command> [options]`

**Commands:**

-   `start [model_base] [ctx_size]`: Start the Ollama server.
    -   `ollamaX start llama3:8b 8192`
-   `stop`: Stop the Ollama server.
    -   `ollamaX stop`
-   `restart [model_base] [ctx_size]`: Restart the server with a new configuration.
    -   `ollamaX restart`
-   `list`: List all your local Ollama models.
    -   `ollamaX list`
-   `switch <model_base> [ctx_size]`: Stop the current server and start a new one with a different model.
    -   `ollamaX switch qwen2.5-coder:7b`

## Contributing

Contributions are welcome! If you have ideas for new features or improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.