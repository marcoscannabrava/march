#!/bin/bash
PARENT_DIR="$(dirname "$CUR_DIR")"

mkdir -p "$HOME/.config/omarchy/branding"
if [ -f "$HOME/.config/omarchy/branding/about.txt" ]; then
    mv "$HOME/.config/omarchy/branding/about.txt" "$HOME/.config/omarchy/branding/about.txt.bkp"
fi

ln -s "$PARENT_DIR/about.txt" "$HOME/.config/omarchy/branding/about.txt"