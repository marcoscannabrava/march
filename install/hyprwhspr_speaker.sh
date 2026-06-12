#!/bin/bash

# Configure hyprwhspr to transcribe speaker (system) output and install the
# hyprwhspr-speaker toggle script to ~/.local/bin.
set -Eeuo pipefail

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"
CONFIG="$HOME/.config/hyprwhspr/config.json"
BIN_DIR="$HOME/.local/bin"

echo "Configuring hyprwhspr at $CONFIG"
if [ ! -f "$CONFIG" ]; then
	echo "ERROR: $CONFIG not found. Is hyprwhspr installed?" >&2
	exit 1
fi

if ! command -v jq &> /dev/null; then
	echo "ERROR: jq is required to edit the config." >&2
	exit 1
fi

# Pin capture to the generic 'pipewire' device (follows the default source on
# each new recording stream) and disable settings that sabotage capture.
tmp="$(mktemp)"
jq '.audio_device_name = "pipewire" | .audio_ducking = false | .mute_detection = false' \
	"$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
echo "Set audio_device_name=pipewire, audio_ducking=false, mute_detection=false"

echo "Symlinking hyprwhspr-speaker to $BIN_DIR"
mkdir -p "$BIN_DIR"
ln -sfn "$PARENT_DIR/scripts/hyprwhspr-speaker" "$BIN_DIR/hyprwhspr-speaker"

echo "Restarting hyprwhspr.service"
systemctl --user restart hyprwhspr.service

echo ""
echo "hyprwhspr speaker capture installed!"
echo ""
echo "To transcribe speaker audio:"
echo "  1. hyprwhspr-speaker on"
echo "  2. trigger recording with the hyprwhspr keybind (default SUPER+ALT+D)"
echo "  3. hyprwhspr-speaker off   # restore mic as default source"
