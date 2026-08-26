#!/bin/bash

# Make the dumb copilot key useful.
CUR_DIR="$(dirname "$(readlink -f "$0")")"

yay -S --needed keyd
sudo systemctl enable --now keyd
sudo ln -sfn "$CUR_DIR/keymap.keyd.conf" "/etc/keyd/default.conf"
sudo keyd reload
