# Backup Systemd Timers

This directory contains systemd service and timer units for automated backups, replacing the previous cron-based setup.

## Services

### backup.service
Backs up the home directory to Backblaze using rclone.

**Schedule:** Monday, Wednesday, and Friday at 2:00 PM  
**Timer:** backup.timer  
**Log:** /var/log/backup.log

### backup-gdrive.service
Backs up Google Drive to Backblaze using rclone.

**Schedule:** Sunday at 3:00 AM  
**Timer:** backup-gdrive.timer  
**Log:** /var/log/backup.log

## Installation

Run the installation script:
```bash
./install/backup_systemd.sh
```

## Management

### Check timer status
```bash
systemctl status backup.timer
systemctl status backup-gdrive.timer
```

### List all timers and see next scheduled run
```bash
systemctl list-timers
```

### View service logs
```bash
# View recent logs
journalctl -u backup.service
journalctl -u backup-gdrive.service

# Follow logs in real-time
journalctl -u backup.service -f

# View log file
tail -f /var/log/backup.log
```

### Manually trigger a backup
```bash
sudo systemctl start backup.service
sudo systemctl start backup-gdrive.service
```

### Disable timers
```bash
sudo systemctl stop backup.timer
sudo systemctl disable backup.timer

sudo systemctl stop backup-gdrive.timer
sudo systemctl disable backup-gdrive.timer
```

### Re-enable timers
```bash
sudo systemctl enable --now backup.timer
sudo systemctl enable --now backup-gdrive.timer
```

## New Systemd Setup
- **backup.timer:** Mon, Wed, Fri at 2:00 PM → `backup.service`
- **backup-gdrive.timer:** Sunday at 3:00 AM → `backup-gdrive.service`

## Troubleshooting

### Timer not running
```bash
# Check if timer is enabled
systemctl is-enabled backup.timer

# Check timer status
systemctl status backup.timer

# Restart timer
sudo systemctl restart backup.timer
```

### Service failing
```bash
# Check service logs
journalctl -u backup.service -n 50

# Check if script is executable
ls -la /home/marcos/code/march/scripts/backup

# Test script manually
/home/marcos/code/march/scripts/backup
```

### Check next scheduled run
```bash
systemctl list-timers --all
