#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"

cp -r "$(dirname "$CUR_DIR")/wallpapers/"* "$HOME/.config/omarchy/current/theme/backgrounds/"
