# fixes

Post-install fixes / workarounds for known issues that show up on a fresh
Omarchy device provisioned by `march`. Each script is **idempotent** and safe
to re-run.

Run a fix directly:

```sh
./fixes/fix-hyprwhspr-wayland-display.sh
```

| Script | Fixes |
|--------|-------|
| `fix-hyprwhspr-wayland-display.sh` | hyprwhspr dictation (SUPER+ALT+D) plays the sound but inserts no text — the user systemd service starts without `WAYLAND_DISPLAY`, so `wl-copy` text injection fails. Adds a systemd drop-in that detects the live Wayland socket and exports `WAYLAND_DISPLAY`. |
