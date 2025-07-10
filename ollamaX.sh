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

        echo "🔧 Creating Modelfile for $MODEL_NAME (Context: $CTX_SIZE)"
        cat <<EOF > "$MODELFILE_PATH"
FROM $MODEL_BASE
PARAMETER num_ctx $CTX_SIZE
EOF

        echo "📦 Building Ollama model: $MODEL_NAME"
        ollama create "$MODEL_NAME" -f "$MODELFILE_PATH"

        echo "🚀 Starting Ollama server in background..."
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
        ollama list
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
    *)
        echo "Error: Unknown command: $COMMAND"
        usage
        ;;
esac