#!/bin/bash

# Installation script for OllamaX

# The source script
SOURCE_SCRIPT="ollamaX.sh"
# The name of the command to be installed
INSTALL_NAME="ollamaX"
# The installation directory
INSTALL_DIR="/usr/local/bin"

# Check if the source script exists
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "Error: Source script '$SOURCE_SCRIPT' not found."
    echo "Please run this script from the same directory as '$SOURCE_SCRIPT'."
    exit 1
fi

echo "Installing '$INSTALL_NAME' to '$INSTALL_DIR'..."

# Copy the script to the installation directory
# Use sudo for permissions
if sudo cp "$SOURCE_SCRIPT" "$INSTALL_DIR/$INSTALL_NAME"; then
    echo "Script copied to '$INSTALL_DIR/$INSTALL_NAME'."
else
    echo "Error: Failed to copy script. Do you have sudo permissions?"
    exit 1
fi

# Make the installed script executable
if sudo chmod +x "$INSTALL_DIR/$INSTALL_NAME"; then
    echo "Made the script executable."
else
    echo "Error: Failed to make script executable."
    exit 1
fi

echo
echo "✅ Installation complete!"
echo "You can now run '$INSTALL_NAME' from anywhere in your terminal."