#!/bin/bash

REPO_DIR="$(dirname "$(readlink -f "$0")")"

if [ -f $REPO_DIR/utils.sh ]; then source $REPO_DIR/utils.sh;
else echo "utils.sh not found."; exit 1; fi

print_logo
cd "$REPO_DIR"

# Converge target to a link to src.
function ensure_link() {
    local src="$1"
    local target="$2"
    local runner=()
    [ "$3" = "sudo" ] && runner=(sudo)

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        log_yellow "$target already linked."
        return 0
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup "$target" || return 1
    fi

    "${runner[@]}" mkdir -p "$(dirname "$target")"
    "${runner[@]}" ln -sfn "$src" "$target"
    log_green "linked: $target"
}

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -p, --packages       Install packages"
    echo "  -o, --omarchy        Install Omarchy"
    echo "  -s, --symlink        Symlink dotfiles"
    echo "  -w, --wallpapers     Install wallpapers and splashscreen"
    echo "  -k, --keymap         Install keymap configuration"
    echo ""
    echo "Example: $0 -pswk # installs packages, symlinks files, wallpapers, and keymap"
    echo ""
    echo "Check machine drift with: install/doctor.sh"
    exit 0
}

INSTALL_OMARCHY=false
INSTALL_PACKAGES=false
SYMLINK_FILES=false
INSTALL_WALLPAPERS_AND_SPLASHSCREEN=false
INSTALL_KEYMAP=false

if [ $# -eq 0 ]; then usage; fi

while getopts "poswkh" option; do
    case $option in
        p)
            log_purple "-packages: package installation...\n\n"
            INSTALL_PACKAGES=true
            ;;
        o)
            log_purple "-omarchy: omarchy installation...\n\n"
            INSTALL_OMARCHY=true
            ;;
        s)
            log_purple "-symlink: symlinking files...\n\n"
            SYMLINK_FILES=true
            ;;
        w)
            log_purple "-wallpapers: wallpapers and splashscreen installation...\n\n"
            INSTALL_WALLPAPERS_AND_SPLASHSCREEN=true
            ;;
        k)
            log_purple "-keymap: keymap configuration...\n\n"
            INSTALL_KEYMAP=true
            ;;
        h|*)
            usage
            ;;
    esac
done

if [ $INSTALL_OMARCHY = true ]; then
    git submodule update --init omarchy
    bash omarchy/boot.sh
    exit 0
fi

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
        sudo pacman -S --needed --noconfirm reflector
        reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist # sort mirrors by speed

        log_purple "installing yay..."
        rm -rf "$HOME/.yay-bin" # drop a clone from a crashed run
        if ! git clone https://aur.archlinux.org/yay-bin.git "$HOME/.yay-bin"; then
            log_red "failed to clone yay. please install it manually."
            exit 1
        fi
        if ! (cd "$HOME/.yay-bin" && makepkg -si); then
            log_red "failed to build yay. please install it manually."
            exit 1
        fi
        rm -rf "$HOME/.yay-bin"
        log_green "yay installed successfully."
    fi


    log_purple "#######################################"
    log_purple "######### installing packages #########"
    log_purple "#######################################\n"
    log_purple "updating package database..."
    yay -Syu

    log_purple "installing packages from pkg.list..."
    PKG_LIST="$(grep -vE '^#|^$' pkg.list | cut -d'|' -f1 | xargs)"
    yay -S --needed --noconfirm $PKG_LIST

    log_purple "installing zsh, oh-my-zsh, and plugins..."
    install/zsh.sh
fi

if [ $SYMLINK_FILES = true ]; then
    log_purple "#######################################"
    log_purple "######### symlinking dotfiles #########"
    log_purple "#######################################\n"
    for file in $(find config -type f); do
        # config/_home keeps its subpath under $HOME
        if [[ "$file" == config/_home/* ]]; then
            target="$HOME/${file#config/_home/}"
        else
            target="$HOME/.$file"
        fi
        ensure_link "$REPO_DIR/$file" "$target"
    done

    log_purple "############################################"
    log_purple "###### symlinking claude code skills #######"
    log_purple "############################################\n"
    for dir in "$REPO_DIR"/claude/plugins/ship/skills/*/; do
        src="${dir%/}"
        ensure_link "$src" "$HOME/.claude/skills/$(basename "$src")"
    done

    log_purple "######################################"
    log_purple "######### symlinking scripts #########"
    log_purple "######################################\n"
    sudo install -d -m 0755 "/usr/local/lib/march"
    for file in $(find scripts -type f); do
        script_name="$(basename "$file")"
        if [[ "$script_name" =~ ^(backup|backup_gdrive|restore)$ ]]; then
            log_yellow "$file is installed by install/backup_systemd.sh."
            continue
        fi
        ensure_link "$REPO_DIR/$file" "/usr/local/lib/march/$script_name" sudo
    done

    # keep timer in PATH
    ensure_link "$REPO_DIR/scripts/timer" "$HOME/.local/bin/timer"

    log_purple "######################################"
    log_purple "######### symlinking sounds ##########"
    log_purple "######################################\n"
    for file in $(find sounds -type f); do
        ensure_link "$REPO_DIR/$file" "$HOME/.local/share/sounds/$(basename "$file")"
    done
fi

if [ $INSTALL_WALLPAPERS_AND_SPLASHSCREEN = true ]; then
    log_purple "#################################################"
    log_purple "##### installing wallpapers and splash screen ###"
    log_purple "#################################################\n"
    install/wallpapers.sh
    install/splashscreen.sh
    install/branding.sh
fi

if [ $INSTALL_KEYMAP = true ]; then
    log_purple "##########################################"
    log_purple "######### configuring keymap #############"
    log_purple "##########################################\n"
    install/keymap.sh
fi

read -p "Do you want to install VSCode extensions? (y/n): " install_vscode
if [[ "$install_vscode" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######## installing VSCode extensions ####"
    log_purple "##########################################\n"
    install/vscode_extensions.sh
fi

read -p "Do you want to install webapps? (y/n): " install_webapps
if [[ "$install_webapps" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######### installing webapps #############"
    log_purple "##########################################\n"
    install/webapps.sh
fi

read -p "Do you want to install the backup systemd timers? Be sure to update the scripts. (y/n): " install_backups
if [[ "$install_backups" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######### installing backup timers #######"
    log_purple "##########################################\n"
    install/backup_systemd.sh
fi

log_green "##########################################"
log_green "######### INSTALLATION COMPLETE! #########"
log_green "##########################################"