#!/bin/bash

ORIGINAL_DIR="$(pwd)"
REPO_DIR="$(dirname "$(readlink -f "$0")")"

if [ -f $REPO_DIR/utils.sh ]; then source $REPO_DIR/utils.sh;
else echo "utils.sh not found."; exit 1; fi

INSTALL_OMARCHY=false
INSTALL_PACKAGES=false
SYMLINK_FILES=false
INSTALL_WALLPAPERS_AND_SPLASHSCREEN=false
INSTALL_KEYMAP=false

while getopts "poswkh:" option; do
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
            echo ">>>" $option
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
            exit 0
            ;;
    esac
done

if [ $INSTALL_OMARCHY = true ]; then
    eval omarchy/boot.sh
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
    yay -Syu

    log_purple "installing packages from pkg.list..."
    PKG_LIST="$(grep -vE '^#|^$' pkg.list | cut -d'|' -f1 | xargs)"
    yay -S --needed --noconfirm $PKG_LIST

    if ! command -v zsh &> /dev/null; then
        log_purple "installing zsh, oh-my-zsh, and plugins..."
        ./install/zsh.sh
    fi
fi

if [ $SYMLINK_FILES = true ]; then
    log_purple "#######################################"
    log_purple "######### symlinking dotfiles #########"
    log_purple "#######################################\n"
    for file in $(find config -type f); do
        # files in config/_home are symlinked to $HOME, otherwise to $HOME/.config
        if [[ "$file" == config/_home/* ]]; then
            target="$HOME/$(basename "$file")"
        else
            target="$HOME/.$file"
        fi
        if [ -L "$HOME/.$file" ]; then
            log_yellow "$file already linked."
            continue
        fi
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
    mkdir -p "/usr/local/lib/march"
    for file in $(find scripts -type f); do
        target="/usr/local/lib/march/$(basename "$file")"
        if [ -L "$target" ]; then
            log_yellow "$file already linked."
            continue
        fi
        if [ -e "$target" ]; then
            backup "$target"
        fi
        sudo ln -s "$REPO_DIR/$file" "$target"
        log_green "linked: $target"
    done

    # symlink timer to ~/.local/bin so it's in PATH
    sudo ln -s "$REPO_DIR/scripts/timer" "$HOME/.local/bin/timer"

    log_purple "######################################"
    log_purple "######### symlinking sounds ##########"
    log_purple "######################################\n"
    mkdir -p "$HOME/.local/share/sounds"
    for file in $(find sounds -type f); do
        target="$HOME/.local/share/sounds/$(basename "$file")"
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
fi

if [ $INSTALL_WALLPAPERS_AND_SPLASHSCREEN = true ]; then
    log_purple "#################################################"
    log_purple "##### installing wallpapers and splash screen ###"
    log_purple "#################################################\n"
    eval install/wallpapers.sh
    eval install/splashscreen.sh
    eval install/branding.sh
fi

if [ $INSTALL_KEYMAP = true ]; then
    log_purple "##########################################"
    log_purple "######### configuring keymap #############"
    log_purple "##########################################\n"
    eval install/keymap.sh
fi

read -p "Do you want to install VSCode extensions? (y/n): " install_vscode
if [[ "$install_vscode" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######## installing VSCode extensions ####"
    log_purple "##########################################\n"
    eval install/vscode_extensions.sh
fi

read -p "Do you want to install webapps? (y/n): " install_webapps
if [[ "$install_webapps" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######### installing webapps #############"
    log_purple "##########################################\n"
    eval install/webapps.sh
fi

read -p "Do you want to install the backup crons? Be sure to update the scripts. (y/n): " install_crons
read -p "Crontab or systemd? Abort? (c/s/a): " cron_type
if [[ "$install_crons" =~ ^[Yy]$ ]]; then
    log_purple "##########################################"
    log_purple "######### installing backup crons ########"
    log_purple "##########################################\n"
    if [[ "$cron_type" =~ ^[Cc]$ ]]; then
        eval install/backup_crons.sh
    elif [[ "$cron_type" =~ ^[Ss]$ ]]; then
        eval install/backup_systemd.sh
    else
        log_yellow "Skipping backup cron installation."
    fi
fi

log_green "##########################################"
log_green "######### INSTALLATION COMPLETE! #########"
log_green "##########################################"