#!/bin/bash

# Step 1: Stop any existing Ollama server process
echo "🛑 Stopping existing Ollama server..."
if pgrep -x "ollama" > /dev/null
then
    pkill -x "ollama"
    echo "Ollama server stopped."
    sleep 2 # Give it a moment to shut down
else
    echo "Ollama server is not running."
fi


# Step 2: Start the server again using the setup script
echo "🚀 Restarting Ollama server..."
./setup-qwen-ctx32k-server.sh

echo "✅ Restart complete."