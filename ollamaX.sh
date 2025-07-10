#!/bin/bash

# A simple CLI wrapper for managing Ollama models

# --- Configuration ---
# Default values, can be overridden by command-line arguments
DEFAULT_MODEL_BASE="qwen2.5-coder:7b"
DEFAULT_CTX_SIZE_KB=4
MODELFILE_PATH="./Modelfile"

# --- Helper Functions ---
usage() {
    echo "Usage: ollamaX <command> [options]"
    echo
    echo "Commands:"
    echo "  start [model_base] [ctx_size_kb]   Start the Ollama server with a specific model."
    echo "  stop                            Stop the Ollama server."
    echo "  restart [model_base] [ctx_size_kb] Restart the Ollama server."
    echo "  list                            List locally available Ollama models."
    echo "  switch <model_name> [ctx_size_kb]   Switch to a different running model."
    echo "  unload                          Unload the current model from memory."
    echo "  clean [configs|all]             Remove models. 'configs' removes only ollamaX models, 'all' removes all models."
    echo "  recommend-ctx <model_base>      Recommend a context size for a model (placeholder)."
    echo
    echo "Example:"
    echo "  ollamaX start llama3:8b 8192"
    echo "  ollamaX stop"
    exit 1
}

# --- Main Logic ---
interactive_wizard() {
    echo "Welcome to the OllamaX CLI Wizard!"
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
                    echo "No local models found. Please pull a model first with 'ollama pull <model_name>'."
                    break
                fi

                PS3="Select a model to start: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo "Invalid selection."
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
                    echo "No local models found to switch to."
                    break
                fi

                PS3="Select a model to switch to: "
                select model_base in "${models[@]}"; do
                     if [[ -n "$model_base" ]]; then
                        break
                    else
                        echo "Invalid selection."
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
                    echo "No local models found."
                    break
                fi

                PS3="Select a model for context recommendation: "
                select model_base in "${models[@]}"; do
                    if [[ -n "$model_base" ]]; then
                        "$0" recommend-ctx "$model_base"
                        break
                    else
                        echo "Invalid selection."
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
                        *) echo "Invalid option." ;;
                    esac
                done
                break
                ;;
            "Unload Current Model")
                "$0" unload
                break
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
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

        # Sanitize model name for the tag
        SANITIZED_MODEL_BASE=$(echo "$MODEL_BASE" | tr ':' '-')
        MODEL_NAME="${SANITIZED_MODEL_BASE}-ctx${CTX_SIZE_KB}k"

        echo
        echo "---"
        echo "Configuration Summary:"
        echo "  Model to run:   $MODEL_BASE"
        echo "  Context size:   ${CTX_SIZE_KB}k (${CTX_SIZE} tokens)"
        echo "  Final model tag:  $MODEL_NAME"
        echo "---"
        echo

        # Check if the model already exists
        if ollama list | awk '{print $1}' | grep -q "^${MODEL_NAME}$"; then
            echo "✅ Model '$MODEL_NAME' already exists. Reusing it."
        else
            echo "🔧 Creating Modelfile..."
            cat <<EOF > "$MODELFILE_PATH"
FROM $MODEL_BASE
PARAMETER num_ctx $CTX_SIZE
EOF

            echo "📦 Building Ollama model..."
            ollama create "$MODEL_NAME" -f "$MODELFILE_PATH"
        fi

        echo "🚀 Starting Ollama server..."
        ollama serve > ollama-server.log 2>&1 &
        sleep 2

        echo "🔥 Warming up model: $MODEL_NAME"
        # Suppress curl output for cleaner CLI experience
        curl -s http://localhost:11434/api/generate -d "{
          \"model\": \"$MODEL_NAME\",
          \"prompt\": \"Hello\",
          \"stream\": false
        }" > /dev/null

        echo "✅ Ollama is serving '$MODEL_NAME' at http://localhost:11434"
        ;;
    stop)
        echo "🛑 Stopping Ollama server..."
        if pgrep -x "ollama" > /dev/null
        then
            pkill -x "ollama"
            echo "Ollama server stopped."
        else
            echo "Ollama server is not running."
        fi
        ;;
    restart)
        echo "🔄 Restarting Ollama server..."
        # Call the stop command from within the script
        "$0" stop
        # Call the start command, passing along any arguments
        "$0" start "$@"
        ;;
    list)
        echo "📋 Listing locally available Ollama models..."
        
        # Check if server is running
        if ! pgrep -x "ollama" > /dev/null; then
            ollama list
            echo
            echo "ℹ️ Ollama server is not running. Start it to see the active model."
            exit 0
        fi

        # Try to get the running model
        # Use a timeout to prevent long waits if the server is unresponsive
        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            # If curl fails, times out, or response is not valid JSON, fall back to simple list
            ollama list
            echo
            echo "⚠️ Could not determine the running model. The server might be starting up or unresponsive."
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
                echo "$line  (running)"
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
        echo "🔄 Switching to model $MODEL_BASE..."
        # Call the restart command logic
        "$0" restart "$@"
        ;;
    unload)
        echo "🔌 Unloading current model..."
        if ! pgrep -x "ollama" > /dev/null; then
            echo "ℹ️ Ollama server is not running. Nothing to unload."
            exit 0
        fi

        running_model_json=$(curl -s --max-time 2 http://localhost:11434/api/ps)
        if [ -z "$running_model_json" ] || ! echo "$running_model_json" | jq -e . >/dev/null 2>&1; then
            echo "⚠️ Could not determine the running model. The server might be starting up or unresponsive."
            exit 0
        fi
        
        running_model=$(echo "$running_model_json" | jq -r '.models[0].name')

        if [ -z "$running_model" ] || [ "$running_model" == "null" ]; then
            echo "✅ No model is currently loaded."
            exit 0
        fi

        echo "Unloading model: $running_model"
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
            echo "✅ Model '$running_model' has been successfully unloaded."
        else
            echo "❌ Failed to unload model '$running_model'. It may still be in use."
        fi
        ;;
    recommend-ctx)
        MODEL_BASE=$1
        if [ -z "$MODEL_BASE" ]; then
            echo "Error: Model base must be provided for recommendation."
            usage
        fi
        echo "🧠 Recommending context size for $MODEL_BASE..."
        echo "This feature is a placeholder."
        echo "A proper implementation requires hardware detection and model-specific data, which is best done in a more advanced script (e.g., Python)."
        echo "For now, please consult the model's documentation for recommendations."
        ;;
    clean)
        SUB_COMMAND=$1
        case "$SUB_COMMAND" in
            configs)
                echo "🗑️ Removing all model configurations created by ollamaX..."
                models_to_remove=$(ollama list | awk 'NR>1 {print $1}' | grep -- '-ctx[0-9]\+k')
                if [ -z "$models_to_remove" ]; then
                    echo "No ollamaX model configurations found to remove."
                else
                    echo "$models_to_remove" | while IFS= read -r model; do
                        echo "   - Removing $model"
                        ollama rm "$model"
                    done
                    echo "✅ Cleanup complete."
                fi
                ;;
            all)
                read -p "⚠️ This will remove ALL Ollama models on your system. Are you sure? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "🗑️ Removing ALL Ollama models..."
                    models_to_remove=$(ollama list | awk 'NR>1 {print $1}')
                    if [ -z "$models_to_remove" ]; then
                        echo "No models found to remove."
                    else
                        echo "$models_to_remove" | while IFS= read -r model; do
                            echo "   - Removing $model"
                            ollama rm "$model"
                        done
                        echo "✅ Cleanup complete."
                    fi
                else
                    echo "Cleanup cancelled."
                fi
                ;;
            *)
                echo "Error: Invalid clean command. Use 'configs' or 'all'."
                usage
                ;;
        esac
        ;;
    *)
        echo "Error: Unknown command: $COMMAND"
        usage
        ;;
esac