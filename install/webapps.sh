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

# Copy all .desktop files and replace $HOME with actual path
for desktop_file in "$WEBAPP_DIR"/*.desktop; do
    if [ -f "$desktop_file" ]; then
        filename=$(basename "$desktop_file")
        echo "  Installing $filename"
        sed "s|\$HOME|$HOME|g" "$desktop_file" > "$TARGET_DIR/$filename"
    fi
done

# Copy all icon files (png, jpg, svg, etc.)
for icon_file in "$WEBAPP_DIR"/*.{png,jpg,jpeg,svg,ico}; do
    if [ -f "$icon_file" ]; then
        filename=$(basename "$icon_file")
        echo "  Installing icon $filename"
        cp "$icon_file" "$ICON_DIR/$filename"
    fi
done

echo "Webapps installed successfully!"
