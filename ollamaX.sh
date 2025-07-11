#!/bin/bash

# A simple CLI wrapper for managing Ollama models

# --- Configuration ---
# Default values, can be overridden by command-line arguments
DEFAULT_MODEL_BASE="qwen2.5-coder:7b"
DEFAULT_CTX_SIZE_KB=4
MODELFILE_PATH="./Modelfile"
VERSION="1.7.5"
CONFIG_DIR="$HOME/.ollamaX"
CONFIG_FILE="$CONFIG_DIR/config"

# --- Emojis ---
E_START="🚀"
E_STOP="🛑"
E_RESTART="🔄"
E_LIST="📋"
E_SWITCH="↔️"
E_UNLOAD="🔌"
E_CLEAN="🧹"
E_UPDATE="⬆️"
E_VERSION="ℹ️"
E_SUCCESS="✅"
E_WARN="⚠️"
E_ERROR="❌"
E_INFO="ℹ️"
E_WIZARD="✨"

# --- Theme Loader ---
load_theme() {
    THEME="basic" # Default theme
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi

    case "$THEME" in
        "solarized")
            C_PRIMARY=$'\033[0;35m' # Violet
            C_ACCENT=$'\033[0;36m'  # Cyan
            C_INFO=$'\033[0;34m'      # Blue
            ;;
        "monokai")
            C_PRIMARY=$'\033[0;95m' # Pink/Magenta
            C_ACCENT=$'\033[0;92m'  # Bright Green
            C_INFO=$'\033[0;94m'      # Light Blue
            ;;
        *) # Default to "Terminal Basic"
            C_PRIMARY=$'\033[1;37m' # Bright White
            C_ACCENT=$'\033[1;36m'  # Bright Cyan
            C_INFO=$'\033[1;37m'      # Bright White (same as primary)
            ;;
    esac

    # Standard colors that don't change with theme
    C_OFF=$'\033[0m'
    C_SUCCESS=$'\033[0;32m' # Green
    C_WARN=$'\033[0;33m'    # Yellow
    C_ERROR=$'\033[0;31m'   # Red
}

# Load the theme at the start of the script
load_theme

# --- Helper Functions ---
usage() {
    echo -e "${C_PRIMARY}Usage: ollamaX <command> [options]${C_OFF}"
    echo
    echo -e "${C_PRIMARY}Commands:${C_OFF}"
    echo "  start [model_base] [ctx_size_kb] [--debug]  Start the Ollama server with a specific model."
    echo "  stop                            Stop the Ollama server."
    echo "  restart [model_base] [ctx_size_kb] Restart the Ollama server."
    echo "  list                            List locally available Ollama models."
    echo "  switch <model_name> [ctx_size_kb]   Switch to a different running model."
    echo "  unload                          Unload the current model from memory."
    echo "  clean [configs|all]             Remove models. 'configs' removes only ollamaX models, 'all' removes all models."
    echo "  recommend-ctx <model_base>      Recommend a context size for a model (placeholder)."
    echo "  version                         Show the current version of ollamaX."
    echo "  update                          Update ollamaX to the latest version from GitHub."
    echo "  theme <name>                    Change the color theme (e.g., basic, solarized, monokai)."
    echo
    echo "Example:"
    echo "  ollamaX start llama3:8b 8192"
    echo "  ollamaX stop"
    exit 1
}

# --- Main Logic ---
interactive_wizard() {
    echo -e "${C_PRIMARY}${E_WIZARD} Welcome to the OllamaX CLI Wizard!${C_OFF}"
    PS3="${C_ACCENT}Please enter your choice: ${C_OFF}"
    options=(
        "Start Server"
        "Start Server (Debug Mode)"
        "Stop Server"
        "Restart Server"
        "List Models"
        "Switch Model"
        "Recommend Context Size"
        "Clean Models"
        "Unload Current Model"
        "View Version"
        "Update ollamaX"
        "Change Theme"
        "Quit"
    )
    select opt in "${options[@]}"
    do
        case $opt in
            "Start Server")
                echo "Available models:"
                models=()
                while IFS= read -r line; do
                    models+=("$line")
                done < <(ollama list | awk 'NR>1 {print $1}')
                if [ ${#models[@]} -eq 0 ]; then
                    echo -e "${C_WARN}${E_WARN} No local models found. Please pull a model first with 'ollama pull <model_name>'.${C_OFF}"
                    break
                fi

                PS3="Select a model to start: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo -e "${C_ERROR}Invalid selection.${C_OFF}"
                    fi
                done

                # If the selected model already has a context size, just use it.
                if [[ $model_base == *"-ctx"* ]]; then
                    "$0" start "$model_base"
                else
                    # Otherwise, ask for the context size.
                    read -p "${C_ACCENT}Enter context size in KB [${DEFAULT_CTX_SIZE_KB}]: ${C_OFF}" ctx_size_kb
                    ctx_size_kb=${ctx_size_kb:-$DEFAULT_CTX_SIZE_KB}
                    "$0" start "$model_base" "$ctx_size_kb"
                fi
                break
                ;;
            "Start Server (Debug Mode)")
                echo "Available models:"
                models=()
                while IFS= read -r line; do
                    models+=("$line")
                done < <(ollama list | awk 'NR>1 {print $1}')
                if [ ${#models[@]} -eq 0 ]; then
                    echo -e "${C_WARN}${E_WARN} No local models found. Please pull a model first with 'ollama pull <model_name>'.${C_OFF}"
                    break
                fi

                PS3="Select a model to start: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo -e "${C_ERROR}Invalid selection.${C_OFF}"
                    fi
                done

                # If the selected model already has a context size, just use it.
                if [[ $model_base == *"-ctx"* ]]; then
                    "$0" start "$model_base" --debug
                else
                    # Otherwise, ask for the context size.
                    read -p "${C_ACCENT}Enter context size in KB [${DEFAULT_CTX_SIZE_KB}]: ${C_OFF}" ctx_size_kb
                    ctx_size_kb=${ctx_size_kb:-$DEFAULT_CTX_SIZE_KB}
                    "$0" start "$model_base" "$ctx_size_kb" --debug
                fi
                break
                ;;
            "Stop Server")
                "$0" stop
                break
                ;;
            "Restart Server")
                read -p "Enter model base (optional): " model_base
                read -p "Enter context size in KB (optional): " ctx_size_kb
                "$0" restart "$model_base" "$ctx_size_kb"
                break
                ;;
            "List Models")
                "$0" list
                break
                ;;
            "Switch Model")
                echo "Available models:"
                models=()
                while IFS= read -r line; do
                    models+=("$line")
                done < <(ollama list | awk 'NR>1 {print $1}')
                if [ ${#models[@]} -eq 0 ]; then
                    echo -e "${C_WARN}${E_WARN} No local models found to switch to.${C_OFF}"
                    break
                fi

                PS3="Select a model to switch to: "
                select model_base in "${models[@]}"; do
                     if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo -e "${C_ERROR}Invalid selection.${C_OFF}"
                    fi
                done

                # If the selected model already has a context size, just use it.
                if [[ $model_base == *"-ctx"* ]]; then
                    "$0" switch "$model_base"
                else
                    # Otherwise, ask for the context size.
                    read -p "${C_ACCENT}Enter context size in KB (optional, press Enter for default): ${C_OFF}" ctx_size_kb
                    "$0" switch "$model_base" "$ctx_size_kb"
                fi
                break
                ;;
            "Recommend Context Size")
                echo "Available models:"
                models=()
                while IFS= read -r line; do
                    models+=("$line")
                done < <(ollama list | awk 'NR>1 {print $1}')
                if [ ${#models[@]} -eq 0 ]; then
                    echo -e "${C_WARN}${E_WARN} No local models found.${C_OFF}"
                    break
                fi

                PS3="Select a model for context recommendation: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        "$0" recommend-ctx "$model_base"
                        break
                    else
                        echo -e "${C_ERROR}Invalid selection.${C_OFF}"
                    fi
                done
                break
                ;;
            "Clean Models")
                echo "Clean options:"
                PS3="Please enter your choice: "
                clean_options=("Remove ollamaX configs" "Remove ALL models (configs and models)" "Cancel")
                select clean_opt in "${clean_options[@]}"; do
                    case $REPLY in
                        1)
                            "$0" clean configs
                            break
                            ;;
                        2)
                            "$0" clean all
                            break
                            ;;
                        3)
                            break
                            ;;
                        *) echo -e "${C_ERROR}Invalid option.${C_OFF}" ;;
                    esac
                done
                break
                ;;
            "Unload Current Model")
                "$0" unload
                break
                ;;
            "View Version")
                "$0" version
                break
                ;;
            "Update ollamaX")
                "$0" update
                break
                ;;
            "Change Theme")
                echo "Available themes: basic, solarized, monokai"
                read -p "${C_ACCENT}Enter theme name: ${C_OFF}" theme_name
                "$0" theme "$theme_name"
                break
                ;;
            "Quit")
                break
                ;;
            *) echo -e "${C_ERROR}invalid option $REPLY${C_OFF}";;
        esac
    done
}

COMMAND=$1
if [ -z "$COMMAND" ]; then
    interactive_wizard
    exit 0
fi

shift # Shift past the command argument

case "$COMMAND" in
    start)
        # Parse arguments, allowing for --debug flag
        MODEL_BASE=""
        CTX_SIZE_KB=""
        DEBUG_MODE=false
        for arg in "$@"; do
            case $arg in
                --debug)
                DEBUG_MODE=true
                shift
                ;;
                *)
                if [ -z "$MODEL_BASE" ]; then
                    MODEL_BASE=$arg
                elif [ -z "$CTX_SIZE_KB" ]; then
                    CTX_SIZE_KB=$arg
                fi
                ;;
            esac
        done

        # Set defaults if not provided
        MODEL_BASE=${MODEL_BASE:-$DEFAULT_MODEL_BASE}
        if [[ $MODEL_BASE != *"-ctx"* ]] && [ -z "$CTX_SIZE_KB" ]; then
             CTX_SIZE_KB=${DEFAULT_CTX_SIZE_KB}
        fi


        # If a context size is provided, create a new model config.
        if [ -n "$CTX_SIZE_KB" ]; then
            CTX_SIZE=$((CTX_SIZE_KB * 1024))
            # Strip any existing -ctx...k suffix to avoid duplication
            CLEAN_MODEL_BASE=$(echo "$MODEL_BASE" | sed -E 's/-ctx[0-9]+k//g')
            # Sanitize model name for the tag
            SANITIZED_MODEL_BASE=$(echo "$CLEAN_MODEL_BASE" | tr ':' '-')
            MODEL_NAME="${SANITIZED_MODEL_BASE}-ctx${CTX_SIZE_KB}k"
        else
            # If no context size is provided, use the model name as is.
            MODEL_NAME=$MODEL_BASE
        fi

        echo
        echo "---"
        echo -e "${C_PRIMARY}Configuration Summary:${C_OFF}"
        echo -e "  ${C_INFO}Final model tag:${C_OFF}  $MODEL_NAME"
        if [ -n "$CTX_SIZE_KB" ]; then
             echo -e "  ${C_INFO}From base model:${C_OFF} $MODEL_BASE"
             echo -e "  ${C_INFO}With context size:${C_OFF}   ${CTX_SIZE_KB}k (${CTX_SIZE} tokens)"
        fi
        echo "---"
        echo

        # Check if the model already exists
        if ollama list | awk '{print $1}' | grep -q "^${MODEL_NAME}$"; then
            echo -e "${C_SUCCESS}${E_SUCCESS} Model '$MODEL_NAME' already exists. Reusing it.${C_OFF}"
        else
            echo -e "${C_INFO}${E_WIZARD} Creating Modelfile...${C_OFF}"
            cat <<EOF > "$MODELFILE_PATH"
FROM $MODEL_BASE
PARAMETER num_ctx $CTX_SIZE
EOF

            echo -e "${C_INFO}📦 Building Ollama model...${C_OFF}"
            ollama create "$MODEL_NAME" -f "$MODELFILE_PATH"
        fi

        # Check if server is already running
        if pgrep -x "ollama" > /dev/null; then
            echo -e "${C_INFO}${E_INFO} Ollama server is already running. Proceeding to warm up model...${C_OFF}"
        else
            echo -e "${C_INFO}${E_START} Starting Ollama server...${C_OFF}"
            # Start the server in the background, logging to a file.
            ollama serve > ollama-server.log 2>&1 &
            sleep 2 # Give the server a moment to start
        fi

        # If debug mode is enabled, tail the log file in a new terminal.
        # If debug mode is enabled, tail the log file in the background of the current terminal.
        if [ "$DEBUG_MODE" = true ]; then
            echo -e "${C_WARN}Debug mode enabled. Tailing server log in this terminal...${C_OFF}"
            echo -e "${C_INFO}Press Ctrl+C to stop viewing the log (this will not stop the server).${C_OFF}"
            # Ensure the log file exists before tailing it, then tail in the background.
            touch ollama-server.log
            tail -f ollama-server.log &
        fi

        echo -e "${C_INFO}🔥 Warming up model: $MODEL_NAME${C_OFF}"
        # Suppress curl output for cleaner CLI experience
        curl -s http://localhost:11434/api/generate -d "{
          \"model\": \"$MODEL_NAME\",
          \"prompt\": \"Hello\",
          \"stream\": false
        }" > /dev/null

        echo -e "${C_SUCCESS}${E_SUCCESS} Ollama is serving '$MODEL_NAME' at http://localhost:11434${C_OFF}"
        ;;
    stop)
        echo -e "${C_ERROR}${E_STOP} Stopping Ollama server...${C_OFF}"
        if pgrep -x "ollama" > /dev/null; then
            pkill -x "ollama"
            # Wait until the process is actually gone
            while pgrep -x "ollama" > /dev/null; do
                sleep 0.5
            done
            echo -e "${C_SUCCESS}Ollama server stopped.${C_OFF}"
        else
            echo -e "${C_WARN}Ollama server is not running.${C_OFF}"
        fi
        ;;
    restart)
        echo -e "${C_INFO}${E_RESTART} Restarting Ollama server...${C_OFF}"
        # Call the stop command from within the script
        "$0" stop
        # Call the start command, passing along any arguments
        "$0" start "$@"
        ;;
    list)
        echo -e "${C_INFO}${E_LIST} Listing locally available Ollama models...${C_OFF}"
        
        # Check if server is running
        if ! pgrep -x "ollama" > /dev/null; then
            ollama list
            echo
            echo -e "${C_WARN}${E_INFO} Ollama server is not running. Start it to see the active model.${C_OFF}"
            exit 0
        fi

        # Try to get the running model
        # Use a timeout to prevent long waits if the server is unresponsive
        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            # If curl fails, times out, or response is not valid JSON, fall back to simple list
            ollama list
            echo
            echo -e "${C_ERROR}${E_WARN} Could not determine the running model. The server might be starting up or unresponsive.${C_OFF}"
            exit 0
        fi

        running_model=$(echo "$running_model_json" | jq -r '.models[0].name')

        # Get the header from ollama list
        header=$(ollama list | head -n 1)
        echo "$header"

        # Process the rest of the list
        ollama list | tail -n +2 | while IFS= read -r line; do
            model_name=$(echo "$line" | awk '{print $1}')
            if [ "$model_name" == "$running_model" ]; then
                # Append a marker to the running model line
                echo -e "${C_SUCCESS}$line  (running)${C_OFF}"
            else
                echo "$line"
            fi
        done
        ;;
    switch)
        MODEL_BASE=$1
        if [ -z "$MODEL_BASE" ]; then
            echo "Error: Model base must be provided for switch."
            usage
        fi
        echo -e "${C_INFO}${E_SWITCH} Switching to model $MODEL_BASE...${C_OFF}"
        # Call the restart command logic
        "$0" restart "$@"
        ;;
    unload)
        echo -e "${C_INFO}${E_UNLOAD} Unloading current model...${C_OFF}"
        if ! pgrep -x "ollama" > /dev/null; then
            echo -e "${C_WARN}${E_INFO} Ollama server is not running. Nothing to unload.${C_OFF}"
            exit 0
        fi

        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            echo -e "${C_ERROR}${E_WARN} Could not determine the running model. The server might be starting up or unresponsive.${C_OFF}"
            exit 0
        fi
        
        running_model=$(echo "$running_model_json" | jq -r '.models[0].name')

        if [ -z "$running_model" ] || [ "$running_model" == "null" ]; then
            echo -e "${C_SUCCESS}${E_SUCCESS} No model is currently loaded.${C_OFF}"
            exit 0
        fi

        echo -e "${C_INFO}Unloading model: $running_model${C_OFF}"
        # Using the /api/delete endpoint with "keep_alive: -1" is an undocumented
        # way to force a model to be unloaded from memory without deleting it.
        curl -s -X DELETE http://localhost:11434/api/blobs/sha256:1234 -d '{
          "name": "'"$running_model"'",
          "keep_alive": -1
        }' > /dev/null

        # It can take a moment for the model to fully unload
        sleep 1

        # Verify that the model is no longer running
        new_running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        new_running_model=$(echo "$new_running_model_json" | jq -r '.models[0].name')

        if [ "$running_model" != "$new_running_model" ]; then
            echo -e "${C_SUCCESS}${E_SUCCESS} Model '$running_model' has been successfully unloaded.${C_OFF}"
        else
            echo -e "${C_ERROR}${E_ERROR} Failed to unload model '$running_model'. It may still be in use.${C_OFF}"
        fi
        ;;
    recommend-ctx)
        MODEL_BASE=$1
        if [ -z "$MODEL_BASE" ]; then
            echo "Error: Model base must be provided for recommendation."
            usage
        fi
        echo -e "${C_INFO}🧠 Recommending context size for $MODEL_BASE...${C_OFF}"
        echo -e "${C_WARN}This feature is a placeholder.${C_OFF}"
        echo "A proper implementation requires hardware detection and model-specific data, which is best done in a more advanced script (e.g., Python)."
        echo "For now, please consult the model's documentation for recommendations."
        ;;
    clean)
        SUB_COMMAND=$1
        case "$SUB_COMMAND" in
            configs)
                echo -e "${C_INFO}${E_CLEAN} Removing all model configurations created by ollamaX...${C_OFF}"
                models_to_remove=$(ollama list | awk 'NR>1 {print $1}' | grep -- '-ctx[0-9]\+k')
                if [ -z "$models_to_remove" ]; then
                    echo -e "${C_WARN}No ollamaX model configurations found to remove.${C_OFF}"
                else
                    echo "$models_to_remove" | while IFS= read -r model; do
                        echo "   - Removing $model"
                        ollama rm "$model"
                    done
                    echo -e "${C_SUCCESS}${E_SUCCESS} Cleanup complete.${C_OFF}"
                fi
                ;;
            all)
                read -p "$(echo -e ${C_ERROR}${E_WARN} This will remove ALL Ollama models on your system. Are you sure? [y/N] ${C_OFF})" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${C_ERROR}${E_CLEAN} Removing ALL Ollama models...${C_OFF}"
                    models_to_remove=$(ollama list | awk 'NR>1 {print $1}')
                    if [ -z "$models_to_remove" ]; then
                        echo -e "${C_WARN}No models found to remove.${C_OFF}"
                    else
                        echo "$models_to_remove" | while IFS= read -r model; do
                            echo "   - Removing $model"
                            ollama rm "$model"
                        done
                        echo -e "${C_SUCCESS}${E_SUCCESS} Cleanup complete.${C_OFF}"
                    fi
                else
                    echo -e "${C_WARN}Cleanup cancelled.${C_OFF}"
                fi
                ;;
            *)
                echo "Error: Invalid clean command. Use 'configs' or 'all'."
                usage
                ;;
        esac
        ;;
    version)
        echo -e "${C_PRIMARY}${E_VERSION} ollamaX version ${VERSION}${C_OFF}"
        ;;
    update)
        echo -e "${C_INFO}${E_UPDATE} Checking for updates...${C_OFF}"

        # Find the script's source directory
        SOURCE_PATH=$(readlink -f "$0")
        SOURCE_DIR=$(dirname "$SOURCE_PATH")

        if [ ! -d "$SOURCE_DIR/.git" ]; then
            echo -e "${C_ERROR}${E_ERROR} Could not find the git repository in the source directory: $SOURCE_DIR${C_OFF}"
            echo -e "${C_WARN}Update can only be run if you installed ollamaX by cloning the git repository.${C_OFF}"
            exit 1
        fi

        cd "$SOURCE_DIR"
        
        # Temporarily stash any local changes
        git stash > /dev/null 2>&1
        
        git fetch origin main
        STATUS=$(git status -uno)
        
        if [[ $STATUS == *"Your branch is up to date"* ]]; then
            echo -e "${C_SUCCESS}${E_SUCCESS} You are already running the latest version of ollamaX.${C_OFF}"
            git stash pop > /dev/null 2>&1
            exit 0
        fi
        
        echo -e "${C_WARN}⬇️ An update is available. Pulling changes...${C_OFF}"
        git pull origin main
        
        echo -e "${C_INFO}${E_START} Re-running installer...${C_OFF}"
        if [ -f "install.sh" ]; then
            chmod +x install.sh
            # Re-launch the installer with sudo to ensure it has the correct permissions
            # Re-launch the installer with sudo and the --silent flag
            sudo ./install.sh --silent
        else
            echo -e "${C_ERROR}${E_ERROR} install.sh not found in source directory. Cannot complete update.${C_OFF}"
            git stash pop > /dev/null 2>&1
            exit 1
        fi

        echo -e "${C_SUCCESS}${E_SUCCESS} Update complete! Restarting ollamaX...${C_OFF}"
        
        # Restore any stashed changes
        git stash pop > /dev/null 2>&1
        
        # Relaunch the script with the same arguments it was started with
        exec "$0" "$@"
        ;;
    theme)
        THEME_NAME=$1
        if [ -z "$THEME_NAME" ]; then
            echo -e "${C_ERROR}Error: Theme name must be provided.${C_OFF}"
            echo "Available themes: basic, solarized, monokai"
            exit 1
        fi

        case "$THEME_NAME" in
            "basic"|"solarized"|"monokai")
                mkdir -p "$CONFIG_DIR"
                echo "THEME=\"$THEME_NAME\"" > "$CONFIG_FILE"
                echo -e "${C_SUCCESS}${E_SUCCESS} Theme changed to '$THEME_NAME'. Restarting to apply...${C_OFF}"
                exec "$0"
                ;;
            *)
                echo -e "${C_ERROR}${E_ERROR} Invalid theme name: '$THEME_NAME'${C_OFF}"
                echo "Available themes: basic, solarized, monokai"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Error: Unknown command: $COMMAND"
        usage
        ;;
esac