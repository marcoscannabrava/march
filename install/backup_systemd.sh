#!/bin/bash

set -Eeuo pipefail

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"
SYSTEMD_DIR="/etc/systemd/system"
SCRIPT_DIR="/usr/local/lib/march"
UNITS=(backup.service backup.timer backup-gdrive.service backup-gdrive.timer)
SCRIPTS=(backup backup_gdrive restore)

remove_if_symlink() {
	local path="$1"

	if [ -L "$path" ]; then
		sudo rm -f "$path"
	fi
}

echo "Installing backup scripts to $SCRIPT_DIR"
sudo install -d -m 0755 "$SCRIPT_DIR"
for script in "${SCRIPTS[@]}"; do
	sudo install -m 0755 "$PARENT_DIR/scripts/$script" "$SCRIPT_DIR/$script"
done

echo "Installing systemd units to $SYSTEMD_DIR"
for unit in "${UNITS[@]}"; do
	remove_if_symlink "$SYSTEMD_DIR/$unit"
	sudo install -m 0644 "$PARENT_DIR/systemd/$unit" "$SYSTEMD_DIR/$unit"
done

echo "Removing legacy cron backup hooks"
sudo rm -f /etc/cron.weekly/backup /etc/cron.weekly/backup_gdrive
if crontab -l &> /tmp/march-crontab.current; then
	grep -vE '/etc/cron\.weekly/(backup|backup_gdrive)' /tmp/march-crontab.current > /tmp/march-crontab.filtered || true
	crontab /tmp/march-crontab.filtered
fi
rm -f /tmp/march-crontab.current /tmp/march-crontab.filtered

echo "Checking rclone remotes"
for remote in backblaze google-drive b2; do
	if ! rclone listremotes | grep -qx "$remote:"; then
		echo "WARNING: rclone remote '$remote' is not configured"
	fi
done

sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer backup-gdrive.timer

echo "Backup systemd timers installed successfully!"
echo ""
echo "Check timer status with:"
echo "  systemctl status backup.timer"
echo "  systemctl status backup-gdrive.timer"
echo ""
echo "Check when next run is scheduled:"
echo "  systemctl list-timers --all backup.timer backup-gdrive.timer"
echo ""
echo "View logs with:"
echo "  journalctl -u backup.service"
echo "  journalctl -u backup-gdrive.service"
echo "  tail -f /var/log/backup.log"
