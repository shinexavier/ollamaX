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

# Copy the script to the installation directory
# Use sudo for permissions
sudo cp "$SOURCE_SCRIPT" "$INSTALL_DIR/$INSTALL_NAME"
sudo chmod +x "$INSTALL_DIR/$INSTALL_NAME"