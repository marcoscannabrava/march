CUR_DIR=`pwd`

if [ -f utils.sh ]; then source utils.sh;
else echo "utils.sh not found."; exit 1; fi

log_purple "#######################################"
log_purple "#### package manager configuration ####"
log_purple "#######################################\n"
if ! command -v yay &> /dev/null; then
    log_purple "installing base packages..."
    sudo pacman -Syu --needed git base-devel

    log_purple "configuring pacman..."
    ./config_pacman.sh && \
    log_green "pacman configured successfully." || log_yellow "pacman already configured."

    log_purple "configuring mirrors..."
    sudo pacman -S reflector
    reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist # sort mirrors by speed

    log_purple "installing yay..."
    cd $HOME
    git clone https://aur.archlinux.org/yay-bin.git .yay-bin && \
    cd .yay-bin && \
    makepkg -si && \
    log_green "yay installed successfully." || \
    (log_red "failed to install yay. exiting... please install manually."; exit 1)
    cd $CUR_DIR
fi


log_purple "#######################################"
log_purple "######### installing packages #########"
log_purple "#######################################\n"
log_purple "updating package database..."
sudo yay -Syu

log_purple "installing packages from pkg.list..."
PKG_LIST="$(grep -vE '^#|^$' pkg.list | cut -d'|' -f1 | xargs)"
sudo yay -S --needed --noconfirm $PKG_LIST


log_purple "#######################################"
log_purple "######### symlinking dotfiles #########"
log_purple "#######################################\n"
for file in $(find config -type f); do
    target="$HOME/.$file"
    if [ -e "$target" ]; then
        backup "$target"
    fi
    mkdir -p "$(dirname "$target")"
    ln -s "$CUR_DIR/$file" "$target"
    log_green "linked: $target"
done


log_green "##########################################"
log_green "######### INSTALLATION COMPLETE! #########"
log_green "##########################################"