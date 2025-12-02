#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"

# Make backup scripts executable
chmod +x "$PARENT_DIR/scripts/backup"
chmod +x "$PARENT_DIR/scripts/backup_gdrive"

# Create log file
sudo touch /var/log/backup.log
sudo chown marcos:marcos /var/log/backup.log

# Remove old cron setup if it exists
sudo rm -f /etc/cron.weekly/backup
sudo rm -f /etc/cron.weekly/backup_gdrive
sudo rm -f /var/log/cron.backup.log
# Remove user crontab if it matches our backup cron
if crontab -l 2>/dev/null | grep -q "/etc/cron.weekly/backup"; then
    crontab -r 2>/dev/null || true
fi

# Install systemd service and timer units
sudo cp "$PARENT_DIR/systemd/backup.service" /etc/systemd/system/
sudo cp "$PARENT_DIR/systemd/backup.timer" /etc/systemd/system/
sudo cp "$PARENT_DIR/systemd/backup-gdrive.service" /etc/systemd/system/
sudo cp "$PARENT_DIR/systemd/backup-gdrive.timer" /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start the timers
sudo systemctl enable backup.timer
sudo systemctl enable backup-gdrive.timer
sudo systemctl start backup.timer
sudo systemctl start backup-gdrive.timer

echo "Backup systemd timers installed successfully!"
echo ""
echo "Check timer status with:"
echo "  systemctl status backup.timer"
echo "  systemctl status backup-gdrive.timer"
echo ""
echo "Check when next run is scheduled:"
echo "  systemctl list-timers"
echo ""
echo "View logs with:"
echo "  journalctl -u backup.service"
echo "  journalctl -u backup-gdrive.service"
echo "  tail -f /var/log/backup.log"
