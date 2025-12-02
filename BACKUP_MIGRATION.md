# Backup System Migration: Cron → Systemd Timers

This document explains the migration from cron-based backup scheduling to systemd timers.

## What Changed

### Old System (Cron)
- **User crontab:** Mon, Wed, Fri at 2:00 PM running `/etc/cron.weekly/backup`
- **System cron:** Weekly cron.weekly running both backup scripts
- **Logs:** `/var/log/cron.backup.log`
- **Install script:** `install/backup_crons.sh`

### New System (Systemd)
- **backup.timer:** Mon, Wed, Fri at 2:00 PM → `backup.service`
- **backup-gdrive.timer:** Sunday at 3:00 AM → `backup-gdrive.service`
- **Logs:** `/var/log/backup.log` + journald
- **Install script:** `install/backup_systemd.sh`

## Migration Steps

### 1. Install the new systemd-based backup system
```bash
./install/backup_systemd.sh
```

This script will:
- Remove old cron setup (symlinks in `/etc/cron.weekly/` and user crontab)
- Install systemd service and timer units to `/etc/systemd/system/`
- Enable and start the timers
- Create log file at `/var/log/backup.log`

### 2. Verify the installation
```bash
# Check if timers are active
systemctl list-timers

# Check timer status
systemctl status backup.timer
systemctl status backup-gdrive.timer

# View when next backup is scheduled
systemctl list-timers backup.timer backup-gdrive.timer
```

### 3. Monitor logs
```bash
# View systemd journal logs
journalctl -u backup.service -f

# Or view the log file
tail -f /var/log/backup.log
```

## Advantages of Systemd Timers

1. **Better Logging**
   - Integrated with journald for centralized logging
   - Use `journalctl` to view logs with timestamps and context
   - Still writes to `/var/log/backup.log` for compatibility

2. **Dependency Management**
   - Services wait for network to be online before running
   - Explicit dependency declarations between timers and services

3. **Persistent Timers**
   - If the system is off during a scheduled time, the job runs when the system comes back online
   - Prevents missed backups due to system being turned off

4. **Better Status Reporting**
   - Easy to check if timers are enabled and when they last ran
   - Clear service status with `systemctl status`

5. **More Flexible Scheduling**
   - OnCalendar syntax is more expressive than cron
   - Easier to understand and modify

6. **No Email Dependencies**
   - Cron relies on mail system for notifications
   - Systemd uses native notification mechanisms

## Files Created

```
systemd/
├── backup.service              # Service unit for home directory backup
├── backup.timer                # Timer for Mon/Wed/Fri at 2pm
├── backup-gdrive.service       # Service unit for Google Drive backup
├── backup-gdrive.timer         # Timer for Sunday at 3am
└── README.md                   # Detailed documentation

install/
└── backup_systemd.sh           # Installation script (executable)
```

## Files Deprecated

```
cron → cron.deprecated
install/backup_crons.sh → install/backup_crons.sh.deprecated
```

The original files have been renamed with `.deprecated` extension for reference.

## Common Commands

```bash
# Start a backup manually
sudo systemctl start backup.service
sudo systemctl start backup-gdrive.service

# Stop/disable timers
sudo systemctl stop backup.timer
sudo systemctl disable backup.timer

# Re-enable timers
sudo systemctl enable --now backup.timer

# View logs for a specific service
journalctl -u backup.service -n 50

# Check timer configuration
systemctl cat backup.timer

# Edit timer schedule
sudo systemctl edit --full backup.timer
# Then reload: sudo systemctl daemon-reload
```

## Troubleshooting

If backups aren't running:
1. Check if timers are enabled: `systemctl is-enabled backup.timer`
2. Check timer status: `systemctl status backup.timer`
3. View service logs: `journalctl -u backup.service -n 50`
4. Test script manually: `/home/marcos/code/march/scripts/backup`

## Rollback (if needed)

If you need to revert to the old cron system:

```bash
# Disable and stop systemd timers
sudo systemctl stop backup.timer backup-gdrive.timer
sudo systemctl disable backup.timer backup-gdrive.timer

# Remove systemd units
sudo rm /etc/systemd/system/backup.{service,timer}
sudo rm /etc/systemd/system/backup-gdrive.{service,timer}
sudo systemctl daemon-reload

# Restore old cron setup (after removing .deprecated extension)
mv install/backup_crons.sh.deprecated install/backup_crons.sh
mv cron.deprecated cron
./install/backup_crons.sh
```

## Questions?

See `systemd/README.md` for more detailed documentation and examples.
