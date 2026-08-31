#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
LOGO="$(dirname "$CUR_DIR")/branding/logo.png"

# The omarchy package resets this theme on update.
dir=/usr/share/plymouth/themes/omarchy
if [ -f "$dir/logo.png" ] && [ ! -f "$dir/logo.png.bkp" ]; then
    sudo mv "$dir/logo.png" "$dir/logo.png.bkp"
fi
sudo cp "$LOGO" "$dir/logo.png"
