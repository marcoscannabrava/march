#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"
BRANDING_DIR="$HOME/.config/omarchy/branding"

mkdir -p "$BRANDING_DIR"
if [ -f "$BRANDING_DIR/about.txt" ] && [ ! -L "$BRANDING_DIR/about.txt" ]; then
    mv "$BRANDING_DIR/about.txt" "$BRANDING_DIR/about.txt.bkp"
fi

ln -sfn "$PARENT_DIR/branding/about.txt" "$BRANDING_DIR/about.txt"
