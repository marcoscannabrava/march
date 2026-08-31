#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"
source "$PARENT_DIR/utils.sh"

LOGO="$PARENT_DIR/branding/logo.png"
THEME_DIR=/usr/share/plymouth/themes/omarchy
# Records the logo baked into the current boot image.
STAMP="$THEME_DIR/logo.png.march"

# The omarchy package resets this theme on update.
if [ -f "$THEME_DIR/logo.png" ] && [ ! -f "$THEME_DIR/logo.png.bkp" ]; then
    sudo mv "$THEME_DIR/logo.png" "$THEME_DIR/logo.png.bkp"
fi

if cmp -s "$LOGO" "$THEME_DIR/logo.png"; then
    log_yellow "Splash logo already installed."
else
    sudo cp "$LOGO" "$THEME_DIR/logo.png"
    log_green "Splash logo installed."
fi

# Plymouth reads the theme from the initramfs, so the boot
# password screen keeps the old logo until the image is rebuilt.
if cmp -s "$LOGO" "$STAMP"; then
    log_yellow "Boot image already has the logo."
elif ! command -v limine-mkinitcpio > /dev/null; then
    log_red "limine-mkinitcpio missing. Rebuild the initramfs by hand."
elif sudo limine-mkinitcpio; then
    sudo cp "$LOGO" "$STAMP"
    log_green "Boot image rebuilt with the logo."
else
    log_red "Boot image rebuild failed."
fi
