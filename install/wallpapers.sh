#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"

# Omarchy scans ~/.config/omarchy/backgrounds/<theme> per theme.
THEME_NAME="$(cat "$HOME/.local/state/omarchy/current/theme.name")"
TARGET="$HOME/.config/omarchy/backgrounds/$THEME_NAME"

mkdir -p "$TARGET"
cp -r "$(dirname "$CUR_DIR")/wallpapers/"* "$TARGET/"
