#!/bin/bash

MODEL_NAME="qwen2.5-coder-ctx32k"
MODEL_BASE="qwen2.5-coder:7b"
NUM_CTX=32768
MODELFILE_PATH="./Modelfile"

# Step 1: Create the Modelfile
echo "🔧 Creating Modelfile with context: $NUM_CTX"
cat <<EOF > "$MODELFILE_PATH"
FROM $MODEL_BASE
PARAMETER num_ctx $NUM_CTX
EOF

# Step 2: Build the model
echo "📦 Building Ollama model: $MODEL_NAME"
ollama create "$MODEL_NAME" -f "$MODELFILE_PATH"

# Step 3: Start Ollama server in background (if not already running)
if pgrep -x "ollama" > /dev/null
then
    echo "🟢 Ollama server is already running."
else
    echo "🚀 Starting Ollama server in background..."
    ollama serve > ollama-server.log 2>&1 &
    sleep 2
fi

# Step 4: Pull and warm up the model
echo "🔥 Warming up model: $MODEL_NAME"
curl -s http://localhost:11434/api/generate -d '{
  "model": "'"$MODEL_NAME"'",
  "prompt": "Hello, world!",
  "stream": false
}' > /dev/null

echo "✅ Ollama is serving '$MODEL_NAME' at http://localhost:11434"
echo "You can now connect from RooCode or other LLM clients."
