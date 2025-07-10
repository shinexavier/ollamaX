#!/bin/bash

# This script uninstalls ollamaX by removing it from /usr/local/bin

INSTALL_PATH="/usr/local/bin/ollamaX"

echo "Uninstalling ollamaX..."

if [ -f "$INSTALL_PATH" ]; then
    echo "Found ollamaX at $INSTALL_PATH."
    echo "Removing executable..."
    rm -f "$INSTALL_PATH"
    if [ $? -eq 0 ]; then
        echo "✅ ollamaX has been successfully uninstalled."
    else
        echo "❌ Error: Failed to remove $INSTALL_PATH. Please check permissions."
        exit 1
    fi
else
    echo "ollamaX is not installed at $INSTALL_PATH. Nothing to do."
fi

exit 0