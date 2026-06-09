#!/bin/bash
#
# fix-hyprwhspr-wayland-display.sh
# =============================================================================
# WHAT THIS FIXES
# -----------------------------------------------------------------------------
# Symptom: pressing the hyprwhspr dictation shortcut (SUPER+ALT+D on this setup)
# plays the start/stop "ping" sounds, recording and transcription both succeed,
# but NO transcribed text is ever inserted into the focused window. To the user
# it looks like "I hear the sound but nothing happens".
#
# ROOT CAUSE
# -----------------------------------------------------------------------------
# hyprwhspr runs as a systemd *user* service (~/.config/systemd/user/
# hyprwhspr.service). After it transcribes speech it injects the text by:
#   1. copying the text to the Wayland clipboard with `wl-copy`, then
#   2. issuing a paste keystroke (ydotool / wtype).
#
# `wl-copy` is a Wayland client: it needs the WAYLAND_DISPLAY environment
# variable to know which compositor socket to talk to. A systemd user service
# inherits the user manager's environment *at the moment it is forked*. On this
# Hyprland/uwsm setup, WAYLAND_DISPLAY (e.g. "wayland-1") is imported into the
# user manager environment, but hyprwhspr.service starts before that import
# happens, and the unit itself neither sets nor detects WAYLAND_DISPLAY. Its
# ExecStartPre only *waits for the socket file to exist* — it never exports the
# variable.
#
# As a result the running hyprwhspr process has no WAYLAND_DISPLAY. When it
# spawns `wl-copy`, wl-copy falls back to the default "wayland-0", which does
# not exist (the real socket is "wayland-1"), and dies:
#
#     Failed to connect to a Wayland server: No such file or directory
#     Note: WAYLAND_DISPLAY is unset (falling back to wayland-0)
#     Clipboard+hotkey injection failed: Command '['wl-copy']' returned non-zero exit status 1.
#     [ERROR] Text injection failed (N chars)
#
# The clipboard step fails, so the transcript is silently dropped. The sounds
# play because audio feedback goes through PipeWire and needs no Wayland socket.
#
# THE FIX
# -----------------------------------------------------------------------------
# Add a systemd drop-in override that wraps ExecStart in a small shell which
# detects the live Wayland socket at start time and exports WAYLAND_DISPLAY
# before launching hyprwhspr. We use a drop-in (not an edit of the unit body)
# so the fix survives hyprwhspr re-running its own setup, and we *detect* the
# socket (wayland-[0-9], newest first) instead of hardcoding "wayland-1" so it
# keeps working if the socket name differs on another machine or session.
#
# Drop-in created:
#   ~/.config/systemd/user/hyprwhspr.service.d/wayland-display.conf
#
# This script is idempotent: re-running it just rewrites the drop-in and
# restarts the service.
#
# WHY THIS LIVES IN THE `march` REPO
# -----------------------------------------------------------------------------
# `march` provisions Omarchy on new devices. hyprwhspr is installed as part of
# that setup, so every fresh device hits this same bug. Keeping the fix here
# means it can be re-applied on any new install.
# =============================================================================

set -euo pipefail

DROPIN_DIR="$HOME/.config/systemd/user/hyprwhspr.service.d"
DROPIN_FILE="$DROPIN_DIR/wayland-display.conf"
SERVICE="hyprwhspr.service"

# --- 0. sanity: is the hyprwhspr user service even installed? ----------------
if ! systemctl --user list-unit-files "$SERVICE" >/dev/null 2>&1 \
   || ! systemctl --user list-unit-files | grep -q "^${SERVICE}"; then
    echo "[skip] $SERVICE is not installed for this user — nothing to fix."
    exit 0
fi

# --- 1. write the drop-in override -------------------------------------------
mkdir -p "$DROPIN_DIR"
cat > "$DROPIN_FILE" <<'EOF'
[Service]
# hyprwhspr's text injection runs `wl-copy`, which needs WAYLAND_DISPLAY to
# reach the compositor. The user manager does not reliably export it before
# this service starts, so detect the live wayland socket and export it for the
# process. The empty ExecStart= clears the unit's original ExecStart (required
# before redefining it for a Type=simple service).
ExecStart=
ExecStart=/bin/bash -c 'export WAYLAND_DISPLAY="$(basename "$(ls -t "$XDG_RUNTIME_DIR"/wayland-[0-9] 2>/dev/null | head -1)")"; exec /usr/lib/hyprwhspr/bin/hyprwhspr'
EOF
echo "[ok]  wrote drop-in: $DROPIN_FILE"

# --- 2. reload + restart so the change takes effect now ----------------------
systemctl --user daemon-reload
systemctl --user restart "$SERVICE"
echo "[ok]  reloaded systemd user manager and restarted $SERVICE"

# --- 3. verify WAYLAND_DISPLAY is now present in the running process ---------
pid="$(systemctl --user show -p MainPID --value "$SERVICE" 2>/dev/null || true)"
if [[ -n "${pid:-}" && "$pid" != "0" && -r "/proc/$pid/environ" ]]; then
    if tr '\0' '\n' < "/proc/$pid/environ" | grep -q '^WAYLAND_DISPLAY='; then
        wd="$(tr '\0' '\n' < "/proc/$pid/environ" | grep '^WAYLAND_DISPLAY=')"
        echo "[ok]  hyprwhspr (PID $pid) now has $wd"
    else
        echo "[warn] WAYLAND_DISPLAY still not visible in PID $pid — check 'journalctl --user -u $SERVICE'"
        exit 1
    fi
else
    echo "[warn] could not read environment of $SERVICE (PID '${pid:-none}')"
fi

echo
echo "Done. Open a text field, press SUPER+ALT+D, speak, press again to stop —"
echo "the transcribed text should now be inserted."
