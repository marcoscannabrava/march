#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBAPP_DIR="$SCRIPT_DIR/../webapps"
TARGET_DIR="$HOME/.local/share/applications"
ICON_DIR="$TARGET_DIR/icons"

echo "Installing webapps..."

# Create target directories if they don't exist
mkdir -p "$TARGET_DIR"
mkdir -p "$ICON_DIR"

# Copy all files from webapps directory
for file in "$WEBAPP_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "  Installing $filename"
        if [[ "$filename" == *.desktop ]]; then
            sed "s|\$HOME|$HOME|g" "$file" > "$TARGET_DIR/$filename"
        elif [[ "$filename" =~ \.(png|jpg|jpeg|svg|ico)$ ]]; then
            cp "$file" "$ICON_DIR/$filename"
        fi
    fi
done

echo "Webapps installed successfully!"
