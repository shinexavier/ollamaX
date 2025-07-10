# OllamaX - A CLI Wizard for Ollama

OllamaX is a simple, user-friendly command-line interface (CLI) wrapper for managing [Ollama](https://ollama.ai/) models on macOS. It provides an interactive wizard to help you start, stop, and switch between models without having to remember all the `ollama` commands.

It's designed for developers who want a more streamlined workflow when working with multiple local LLMs.

## Features

- **Interactive Wizard**: Run `ollamaX` without any arguments to launch a step-by-step wizard.
- **Model Management**: Easily start, stop, restart, and switch between your downloaded Ollama models.
- **Context Size Configuration**: Easily set a custom context size (`num_ctx`) in kilobytes (e.g., 4, 8, 16).
- **Standard CLI Interface**: Can also be used with standard command-line arguments for scripting and automation.
- **Simple Installation**: A straightforward installation script to get you up and running quickly.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd ollamaX
    ```

2.  **Run the installation script:**
    This command will first make the script executable and then run it. You will be prompted for your password because the script needs administrator privileges (`sudo`) to place the `ollamaX` command in `/usr/local/bin`.

    ```bash
    chmod +x install.sh && sudo ./install.sh
    ```

3.  **Start using OllamaX!**
    You can now run `ollamaX` from anywhere in your terminal.

    ```bash
    ollamaX
    ```

## Usage

OllamaX can be used in two ways: as an interactive wizard or as a standard command-line tool.

### Interactive Wizard Mode

This is the most user-friendly way to use OllamaX. Simply run the command without any arguments:

```bash
ollamaX
```

You will be greeted with a menu of options.

```
Welcome to the OllamaX CLI Wizard!
1) Start Server
2) Stop Server
3) Restart Server
4) List Models
5) Switch Model
6) Recommend Context Size
7) Quit
Please enter your choice:
```

#### Example: Starting a Server

1.  **Choose an option**: Type `1` and press Enter.
2.  **Select a model**: The script will list all your locally downloaded Ollama models.
    ```
    Available models:
    1) llama3:8b
    2) qwen2.5-coder:7b
    Select a model to start:
    ```
    Type the number corresponding to the model you want to use (e.g., `1`) and press Enter.
3.  **Set the context size**: You will be prompted to enter a context size in Kilobytes (KB).
    ```
    Enter context size in KB [4]:
    ```
    You can type a number (e.g., `8` for 8192) and press Enter, or just press Enter to accept the default value.

The script will then handle the process of creating the Modelfile, building the custom model, and starting the Ollama server.

### Direct Command Mode

For automation and scripting, you can use OllamaX with direct commands and arguments.

**Syntax:** `ollamaX <command> [arguments]`

---

#### `start [model_base] [ctx_size_kb]`

Starts the Ollama server with a specified model and context size.

-   `model_base` (optional): The base model to use (e.g., `llama3:8b`). Defaults to `qwen2.5-coder:7b` if not provided.
-   `ctx_size_kb` (optional): The context size to set, in kilobytes (KB). Defaults to `4` (4096 tokens).

**Example:**
```bash
# Start with a specific model and an 8K context
ollamaX start llama3:8b 8

# Start with the default model and context
ollamaX start
```

---

#### `stop`

Stops any running Ollama server process.

**Example:**
```bash
ollamaX stop
```

---

#### `restart [model_base] [ctx_size_kb]`

Restarts the Ollama server. This is equivalent to running `stop` and then `start`. You can optionally provide a new model and context size (in KB) to change the configuration upon restart.

**Example:**
```bash
# Restart the server with the same configuration
ollamaX restart

# Restart and switch to a new model
ollamaX restart codellama:13b
```

---

#### `list`

Displays a list of all Ollama models that you have downloaded locally. This is a direct pass-through to the `ollama list` command.

**Example:**
```bash
ollamaX list
```

---

#### `switch <model_base> [ctx_size_kb]`

A convenient alias for the `restart` command, making the intent of changing models clearer. It stops the current server and starts a new one with the specified model.

-   `model_base` (required): The new model to switch to.
-   `ctx_size_kb` (optional): The context size for the new model, in kilobytes (KB).

**Example:**
```bash
# Switch to llama3 with a 16K context
ollamaX switch llama3:latest 16
```

## Uninstallation

To remove OllamaX from your system, run the uninstallation script from within the project directory.

This command requires administrator privileges (`sudo`) to remove the executable from `/usr/local/bin`.

```bash
chmod +x uninstall.sh && sudo ./uninstall.sh
```

## Contributing

Contributions are welcome! If you have ideas for new features or improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.