ORIGINAL_DIR=`pwd`
REPO_DIR="$(dirname "$(readlink -f "$0")")"

if [ -f utils.sh ]; then source utils.sh;
else echo "utils.sh not found."; exit 1; fi

INSTALL_PACKAGES=true

while getopt "h,help,n,no-packages" option; do
    case $option in
        n|no-packages)
            log_purple "Skipping package installation."
            echo "Skipping package installation. You can run this script again later to install packages."
            INSTALL_PACKAGES=false
            exit 0
            ;;
        h|help|*)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help           Show this help message"
            echo "  -n, --no-packages    Skip package installation"
            exit 0
            ;;
    esac
done

if [ $INSTALL_PACKAGES = true ]; then
    log_purple "#######################################"
    log_purple "#### package manager configuration ####"
    log_purple "#######################################\n"
    if ! command -v yay &> /dev/null; then
        log_purple "installing base packages..."
        sudo pacman -Syu --needed git base-devel

        log_purple "configuring pacman..."
        config_pacman # from utils.sh

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
        cd $ORIGINAL_DIR
    fi


    log_purple "#######################################"
    log_purple "######### installing packages #########"
    log_purple "#######################################\n"
    log_purple "updating package database..."
    sudo yay -Syu

    log_purple "installing packages from pkg.list..."
    PKG_LIST="$(grep -vE '^#|^$' pkg.list | cut -d'|' -f1 | xargs)"
    sudo yay -S --needed --noconfirm $PKG_LIST
fi


log_purple "#######################################"
log_purple "######### symlinking dotfiles #########"
log_purple "#######################################\n"
for file in $(find config -type f); do
    if [ -L "$HOME/.$file" ]; then
        log_yellow "$file already linked."
        continue
    fi
    target="$HOME/.$file"
    if [ -e "$target" ]; then
        backup "$target"
    fi
    mkdir -p "$(dirname "$target")"
    ln -s "$REPO_DIR/$file" "$target"
    log_green "linked: $target"
done

log_purple "######################################"
log_purple "######### symlinking scripts #########"
log_purple "######################################\n"
mkdir -p "$HOME/.local/lib/march"
for file in $(find scripts -type f); do
    target="$HOME/.local/lib/march/$(basename "$file")"
    if [ -L "$target" ]; then
        log_yellow "$file already linked."
        continue
    fi
    if [ -e "$target" ]; then
        backup "$target"
    fi
    ln -s "$REPO_DIR/$file" "$target"
    log_green "linked: $target"
done



log_green "##########################################"
log_green "######### INSTALLATION COMPLETE! #########"
log_green "##########################################"