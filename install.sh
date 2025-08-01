if [ -f utils.sh ]; then source utils.sh;
else echo "utils.sh not found."; exit 1
fi

log_purple "installing base packages..."
log_purple "------------------------------------"
if ! command -v yay &> /dev/null; then
    sudo pacman -Syu --needed git base-devel
else
    log_green "base packages already installed."
fi


log_purple "configuring pacman..."
log_purple "------------------------------------"
./config_pacman.sh && \
log_green "pacman configured successfully." || \
log_red "minor: pacman configuration update failed..."


log_purple "updating package database..."
log_purple "------------------------------------"
sudo pacman -S reflector yay # install yay aur helper
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist # sort mirrors by speed
sudo yay -Syu


log_purple "installing packages from pkg.list..."
log_purple "------------------------------------"
PKG_LIST="$(grep -vE '^#|^$' pkg.list | cut -d'|' -f1 | xargs)"
sudo yay -S --needed --noconfirm $PKG_LIST


# todo:
# install fonts
# symlink config files

log_green "installation complete!"
log_green "------------------------------------"