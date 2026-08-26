# Backup System Migration: Cron To Systemd Timers

This document explains the migration from cron-based backup scheduling to
systemd timers.

## What Changed

### Old System

- User crontab ran `/etc/cron.weekly/backup` on Monday, Wednesday, and Friday.
- System cron could run both backup scripts weekly.
- Logs went to `/var/log/cron.backup.log`.
- Installed hooks were symlinks into the repository.

### New System

- `backup.timer`: Monday, Wednesday, and Friday at 2:00 PM.
- `backup-gdrive.timer`: Sunday at 3:00 AM.
- Logs are in journald.
- Units are copied to `/etc/systemd/system/`.
- Scripts are copied to `/usr/local/lib/march/`.

The copy-based install prevents units from disappearing if the repository is
moved, renamed, or deleted after installation.

## Migration Steps

```bash
./install/backup_systemd.sh
```

The installer will:

- Remove old cron hooks from `/etc/cron.weekly/` and the user crontab.
- Replace old broken symlinked systemd units with regular files.
- Copy backup scripts to `/usr/local/lib/march/`.
- Reload systemd.
- Enable and start `backup.timer` and `backup-gdrive.timer`.
- Warn if expected rclone remotes are missing.

## Verify

```bash
systemctl status backup.timer
systemctl status backup-gdrive.timer
systemctl list-timers --all backup.timer backup-gdrive.timer
journalctl -u backup.service -n 50
```

## Resource Controls

The services load optional overrides from `/etc/march/backup.env`:

```bash
MARCH_BACKUP_JOBS=1
MARCH_RCLONE_TRANSFERS=2
MARCH_RCLONE_CHECKERS=4
MARCH_RCLONE_BUFFER_SIZE=16M
MARCH_RCLONE_MAX_BUFFER_MEMORY=256M
MARCH_BACKUP_COPY_LINKS=0
MARCH_GDRIVE_RCLONE_TRANSFERS=4
MARCH_GDRIVE_RCLONE_CHECKERS=8
MARCH_GDRIVE_CHUNK_SIZE=32M
```

The home and Google Drive backup scripts share `/tmp/march-backup.lock`, so they
do not overlap. Google Drive backups continue to use `--fast-list`.

## Common Commands

```bash
# Start a backup manually
sudo systemctl start backup.service
sudo systemctl start backup-gdrive.service

# Stop and disable timers
sudo systemctl disable --now backup.timer backup-gdrive.timer

# Re-enable timers
sudo systemctl enable --now backup.timer backup-gdrive.timer

# Check timer configuration
systemctl cat backup.timer
```

## Rollback

```bash
sudo systemctl disable --now backup.timer backup-gdrive.timer
sudo rm -f /etc/systemd/system/backup.{service,timer}
sudo rm -f /etc/systemd/system/backup-gdrive.{service,timer}
sudo systemctl daemon-reload

./install/backup_crons.sh
```
