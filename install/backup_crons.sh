#!/bin/bash

CUR_DIR="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$CUR_DIR")"
chmod +x "$PARENT_DIR/scripts/backup"
chmod +x "$PARENT_DIR/scripts/backup_gdrive"
# system-managed weekly backup
sudo ln -s "$PARENT_DIR/scripts/backup" "/etc/cron.weekly/backup"
sudo ln -s "$PARENT_DIR/scripts/backup_gdrive" "/etc/cron.weekly/backup_gdrive"
sudo touch /var/log/cron.backup.log
sudo chown -R marcos:marcos /etc/cron.weekly/
sudo chown -R marcos:marcos /var/log/cron.backup.log
# user-managed semi-daily backup
crontab "$PARENT_DIR/cron"