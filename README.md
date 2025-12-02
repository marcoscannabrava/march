# dotfiles for a very minimal arch install
```sh
# this install omarchy base
./install.sh -o

# this install customizations
./install.sh -pswk

# backup crons
install/backup_crons.sh

# vscode extensions
install/vscode_extensions.sh
```

# TODO
- fix backup crons to run on Arch that does not come with crontab as a base package