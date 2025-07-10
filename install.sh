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

# Default to verbose
SILENT=false

# Check for a silent flag
if [ "$1" == "--silent" ]; then
    SILENT=true
fi

# Function to echo messages if not in silent mode
log_message() {
    if [ "$SILENT" = false ]; then
        echo "$1"
    fi
}

log_message "Installing 'ollamaX' to '$INSTALL_DIR'..."

# Copy the script to the installation directory
# Use sudo for permissions
sudo cp "$SOURCE_SCRIPT" "$INSTALL_DIR/$INSTALL_NAME"
log_message "Script copied to '$INSTALL_DIR/$INSTALL_NAME'."

# Make the script executable
sudo chmod +x "$INSTALL_DIR/$INSTALL_NAME"
log_message "Made the script executable."

log_message ""
log_message "✅ Installation complete!"
log_message "You can now run 'ollamaX' from anywhere in your terminal."