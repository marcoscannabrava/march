# Backup Systemd Timers

This directory contains systemd service and timer units for automated backups.

## Services

- `backup.service`: backs up selected home directories to `backblaze:poposbkp`.
- `backup-gdrive.service`: backs up Google Drive to `b2:gdrivebkp`.
- `backup.timer`: runs Monday, Wednesday, and Friday at 2:00 PM.
- `backup-gdrive.timer`: runs Sunday at 3:00 AM.

## Installation

```bash
./install/backup_systemd.sh
```

The installer copies units into `/etc/systemd/system/` and scripts into
`/usr/local/lib/march/`. It does not symlink units into this repository, so the
timers keep working if the checkout is moved or removed.

The installer also removes legacy `/etc/cron.weekly/backup` hooks and crontab
entries that call those hooks.

## Management

```bash
# Check timer status
systemctl status backup.timer
systemctl status backup-gdrive.timer

# List scheduled runs
systemctl list-timers --all backup.timer backup-gdrive.timer

# View recent logs
journalctl -u backup.service -n 50
journalctl -u backup-gdrive.service -n 50

# Follow logs
journalctl -u backup.service -f

# Manually trigger a backup
sudo systemctl start backup.service
sudo systemctl start backup-gdrive.service

# Re-enable timers
sudo systemctl enable --now backup.timer backup-gdrive.timer
```

## Resource Tuning

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
do not run at the same time. Google Drive backups still use `--fast-list`.

## Troubleshooting

```bash
# Verify installed scripts
ls -la /usr/local/lib/march/backup /usr/local/lib/march/backup_gdrive

# Test scripts manually
/usr/local/lib/march/backup --dry-run
/usr/local/lib/march/backup_gdrive --dry-run

# Replace broken old symlinked units with copied units
./install/backup_systemd.sh
```
