#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
LOGO="$(dirname "$CUR_DIR")/branding/logo.png"

for dir in /usr/share/plymouth/themes/omarchy "$HOME/.local/share/omarchy/default/plymouth"; do
    if [ -f "$dir/logo.png" ] && [ ! -f "$dir/logo.png.bkp" ]; then
        sudo mv "$dir/logo.png" "$dir/logo.png.bkp"
    fi
    sudo cp "$LOGO" "$dir/logo.png"
done
