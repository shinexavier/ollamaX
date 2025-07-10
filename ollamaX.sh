#!/bin/bash

# A simple CLI wrapper for managing Ollama models

# --- Configuration ---
# Default values, can be overridden by command-line arguments
DEFAULT_MODEL_BASE="qwen2.5-coder:7b"
DEFAULT_CTX_SIZE_KB=4
MODELFILE_PATH="./Modelfile"
VERSION="1.5.1"

# --- Color Definitions ---
C_OFF='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'

# --- Helper Functions ---
usage() {
    echo -e "${C_CYAN}Usage: ollamaX <command> [options]${C_OFF}"
    echo
    echo -e "${C_CYAN}Commands:${C_OFF}"
    echo "  start [model_base] [ctx_size_kb]   Start the Ollama server with a specific model."
    echo "  stop                            Stop the Ollama server."
    echo "  restart [model_base] [ctx_size_kb] Restart the Ollama server."
    echo "  list                            List locally available Ollama models."
    echo "  switch <model_name> [ctx_size_kb]   Switch to a different running model."
    echo "  unload                          Unload the current model from memory."
    echo "  clean [configs|all]             Remove models. 'configs' removes only ollamaX models, 'all' removes all models."
    echo "  recommend-ctx <model_base>      Recommend a context size for a model (placeholder)."
    echo "  version                         Show the current version of ollamaX."
    echo "  update                          Update ollamaX to the latest version from GitHub."
    echo
    echo "Example:"
    echo "  ollamaX start llama3:8b 8192"
    echo "  ollamaX stop"
    exit 1
}

# --- Main Logic ---
interactive_wizard() {
    echo -e "${C_MAGENTA}Welcome to the OllamaX CLI Wizard!${C_OFF}"
    PS3="Please enter your choice: "
    options=(
        "Start Server"
        "Stop Server"
        "Restart Server"
        "List Models"
        "Switch Model"
        "Recommend Context Size"
        "Clean Models"
        "Unload Current Model"
        "View Version"
        "Update ollamaX"
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
                    echo -e "${C_YELLOW}No local models found. Please pull a model first with 'ollama pull <model_name>'.${C_OFF}"
                    break
                fi

                PS3="Select a model to start: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo -e "${C_RED}Invalid selection.${C_OFF}"
                    fi
                done

                read -p "Enter context size in KB [${DEFAULT_CTX_SIZE_KB}]: " ctx_size_kb
                ctx_size_kb=${ctx_size_kb:-$DEFAULT_CTX_SIZE_KB}
                "$0" start "$model_base" "$ctx_size_kb"
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
                    echo -e "${C_YELLOW}No local models found to switch to.${C_OFF}"
                    break
                fi

                PS3="Select a model to switch to: "
                select model_base in "${models[@]}"; do
                     if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo -e "${C_RED}Invalid selection.${C_OFF}"
                    fi
                done

                read -p "Enter context size in KB (optional, press Enter for default): " ctx_size_kb
                "$0" switch "$model_base" "$ctx_size_kb"
                break
                ;;
            "Recommend Context Size")
                echo "Available models:"
                models=()
                while IFS= read -r line; do
                    models+=("$line")
                done < <(ollama list | awk 'NR>1 {print $1}')
                if [ ${#models[@]} -eq 0 ]; then
                    echo -e "${C_YELLOW}No local models found.${C_OFF}"
                    break
                fi

                PS3="Select a model for context recommendation: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        "$0" recommend-ctx "$model_base"
                        break
                    else
                        echo -e "${C_RED}Invalid selection.${C_OFF}"
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
                        *) echo -e "${C_RED}Invalid option.${C_OFF}" ;;
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
            "Quit")
                break
                ;;
            *) echo -e "${C_RED}invalid option $REPLY${C_OFF}";;
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
        MODEL_BASE=${1:-$DEFAULT_MODEL_BASE}
        CTX_SIZE_KB=${2:-$DEFAULT_CTX_SIZE_KB}
        
        # Calculate the actual context size
        CTX_SIZE=$((CTX_SIZE_KB * 1024))

        # Strip any existing -ctx...k suffix to avoid duplication
        CLEAN_MODEL_BASE=$(echo "$MODEL_BASE" | sed -E 's/-ctx[0-9]+k//g')

        # Sanitize model name for the tag
        SANITIZED_MODEL_BASE=$(echo "$CLEAN_MODEL_BASE" | tr ':' '-')
        MODEL_NAME="${SANITIZED_MODEL_BASE}-ctx${CTX_SIZE_KB}k"

        echo
        echo "---"
        echo -e "${C_CYAN}Configuration Summary:${C_OFF}"
        echo -e "  ${C_BLUE}Model to run:${C_OFF}   $MODEL_BASE"
        echo -e "  ${C_BLUE}Context size:${C_OFF}   ${CTX_SIZE_KB}k (${CTX_SIZE} tokens)"
        echo -e "  ${C_BLUE}Final model tag:${C_OFF}  $MODEL_NAME"
        echo "---"
        echo

        # Check if the model already exists
        if ollama list | awk '{print $1}' | grep -q "^${MODEL_NAME}$"; then
            echo -e "${C_GREEN}✅ Model '$MODEL_NAME' already exists. Reusing it.${C_OFF}"
        else
            echo -e "${C_BLUE}🔧 Creating Modelfile...${C_OFF}"
            cat <<EOF > "$MODELFILE_PATH"
FROM $MODEL_BASE
PARAMETER num_ctx $CTX_SIZE
EOF

            echo -e "${C_BLUE}📦 Building Ollama model...${C_OFF}"
            ollama create "$MODEL_NAME" -f "$MODELFILE_PATH"
        fi

        echo -e "${C_BLUE}🚀 Starting Ollama server...${C_OFF}"
        ollama serve > ollama-server.log 2>&1 &
        sleep 2

        echo -e "${C_BLUE}🔥 Warming up model: $MODEL_NAME${C_OFF}"
        # Suppress curl output for cleaner CLI experience
        curl -s http://localhost:11434/api/generate -d "{
          \"model\": \"$MODEL_NAME\",
          \"prompt\": \"Hello\",
          \"stream\": false
        }" > /dev/null

        echo -e "${C_GREEN}✅ Ollama is serving '$MODEL_NAME' at http://localhost:11434${C_OFF}"
        ;;
    stop)
        echo -e "${C_RED}🛑 Stopping Ollama server...${C_OFF}"
        if pgrep -x "ollama" > /dev/null
        then
            pkill -x "ollama"
            echo -e "${C_GREEN}Ollama server stopped.${C_OFF}"
        else
            echo -e "${C_YELLOW}Ollama server is not running.${C_OFF}"
        fi
        ;;
    restart)
        echo -e "${C_BLUE}🔄 Restarting Ollama server...${C_OFF}"
        # Call the stop command from within the script
        "$0" stop
        # Call the start command, passing along any arguments
        "$0" start "$@"
        ;;
    list)
        echo -e "${C_BLUE}📋 Listing locally available Ollama models...${C_OFF}"
        
        # Check if server is running
        if ! pgrep -x "ollama" > /dev/null; then
            ollama list
            echo
            echo -e "${C_YELLOW}ℹ️ Ollama server is not running. Start it to see the active model.${C_OFF}"
            exit 0
        fi

        # Try to get the running model
        # Use a timeout to prevent long waits if the server is unresponsive
        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            # If curl fails, times out, or response is not valid JSON, fall back to simple list
            ollama list
            echo
            echo -e "${C_RED}⚠️ Could not determine the running model. The server might be starting up or unresponsive.${C_OFF}"
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
                echo -e "${C_GREEN}$line  (running)${C_OFF}"
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
        echo -e "${C_BLUE}🔄 Switching to model $MODEL_BASE...${C_OFF}"
        # Call the restart command logic
        "$0" restart "$@"
        ;;
    unload)
        echo -e "${C_BLUE}🔌 Unloading current model...${C_OFF}"
        if ! pgrep -x "ollama" > /dev/null; then
            echo -e "${C_YELLOW}ℹ️ Ollama server is not running. Nothing to unload.${C_OFF}"
            exit 0
        fi

        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            echo -e "${C_RED}⚠️ Could not determine the running model. The server might be starting up or unresponsive.${C_OFF}"
            exit 0
        fi
        
        running_model=$(echo "$running_model_json" | jq -r '.models[0].name')

        if [ -z "$running_model" ] || [ "$running_model" == "null" ]; then
            echo -e "${C_GREEN}✅ No model is currently loaded.${C_OFF}"
            exit 0
        fi

        echo -e "${C_BLUE}Unloading model: $running_model${C_OFF}"
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
            echo -e "${C_GREEN}✅ Model '$running_model' has been successfully unloaded.${C_OFF}"
        else
            echo -e "${C_RED}❌ Failed to unload model '$running_model'. It may still be in use.${C_OFF}"
        fi
        ;;
    recommend-ctx)
        MODEL_BASE=$1
        if [ -z "$MODEL_BASE" ]; then
            echo "Error: Model base must be provided for recommendation."
            usage
        fi
        echo -e "${C_BLUE}🧠 Recommending context size for $MODEL_BASE...${C_OFF}"
        echo -e "${C_YELLOW}This feature is a placeholder.${C_OFF}"
        echo "A proper implementation requires hardware detection and model-specific data, which is best done in a more advanced script (e.g., Python)."
        echo "For now, please consult the model's documentation for recommendations."
        ;;
    clean)
        SUB_COMMAND=$1
        case "$SUB_COMMAND" in
            configs)
                echo -e "${C_BLUE}🗑️ Removing all model configurations created by ollamaX...${C_OFF}"
                models_to_remove=$(ollama list | awk 'NR>1 {print $1}' | grep -- '-ctx[0-9]\+k')
                if [ -z "$models_to_remove" ]; then
                    echo -e "${C_YELLOW}No ollamaX model configurations found to remove.${C_OFF}"
                else
                    echo "$models_to_remove" | while IFS= read -r model; do
                        echo "   - Removing $model"
                        ollama rm "$model"
                    done
                    echo -e "${C_GREEN}✅ Cleanup complete.${C_OFF}"
                fi
                ;;
            all)
                read -p "$(echo -e ${C_RED}⚠️ This will remove ALL Ollama models on your system. Are you sure? [y/N] ${C_OFF})" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${C_RED}🗑️ Removing ALL Ollama models...${C_OFF}"
                    models_to_remove=$(ollama list | awk 'NR>1 {print $1}')
                    if [ -z "$models_to_remove" ]; then
                        echo -e "${C_YELLOW}No models found to remove.${C_OFF}"
                    else
                        echo "$models_to_remove" | while IFS= read -r model; do
                            echo "   - Removing $model"
                            ollama rm "$model"
                        done
                        echo -e "${C_GREEN}✅ Cleanup complete.${C_OFF}"
                    fi
                else
                    echo -e "${C_YELLOW}Cleanup cancelled.${C_OFF}"
                fi
                ;;
            *)
                echo "Error: Invalid clean command. Use 'configs' or 'all'."
                usage
                ;;
        esac
        ;;
    version)
        echo -e "${C_CYAN}ollamaX version ${VERSION}${C_OFF}"
        ;;
    update)
        echo -e "${C_BLUE}🔄 Checking for updates...${C_OFF}"

        # Find the script's source directory
        SOURCE_PATH=$(readlink -f "$0")
        SOURCE_DIR=$(dirname "$SOURCE_PATH")

        if [ ! -d "$SOURCE_DIR/.git" ]; then
            echo -e "${C_RED}❌ Could not find the git repository in the source directory: $SOURCE_DIR${C_OFF}"
            echo -e "${C_YELLOW}Update can only be run if you installed ollamaX by cloning the git repository.${C_OFF}"
            exit 1
        fi

        cd "$SOURCE_DIR"
        
        # Temporarily stash any local changes
        git stash > /dev/null 2>&1
        
        git fetch origin main
        STATUS=$(git status -uno)
        
        if [[ $STATUS == *"Your branch is up to date"* ]]; then
            echo -e "${C_GREEN}✅ You are already running the latest version of ollamaX.${C_OFF}"
            git stash pop > /dev/null 2>&1
            exit 0
        fi
        
        echo -e "${C_YELLOW}⬇️ An update is available. Pulling changes...${C_OFF}"
        git pull origin main
        
        echo -e "${C_BLUE}🚀 Re-running installer...${C_OFF}"
        if [ -f "install.sh" ]; then
            chmod +x install.sh
            # Re-launch the installer with sudo to ensure it has the correct permissions
            # Re-launch the installer with sudo and the --silent flag
            sudo ./install.sh --silent
        else
            echo -e "${C_RED}❌ install.sh not found in source directory. Cannot complete update.${C_OFF}"
            git stash pop > /dev/null 2>&1
            exit 1
        fi

        echo -e "${C_GREEN}✅ Update complete! Restarting ollamaX...${C_OFF}"
        
        # Restore any stashed changes
        git stash pop > /dev/null 2>&1
        
        # Relaunch the script with the same arguments it was started with
        exec "$0" "$@"
        ;;
    *)
        echo "Error: Unknown command: $COMMAND"
        usage
        ;;
esac