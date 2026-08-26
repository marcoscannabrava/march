#!/bin/bash

# Skip when install.sh -s already linked ~/.zshrc.
if [ ! -L "$HOME/.zshrc" ]; then
    echo "source ~/.config/zsh/.zshrc" > ~/.zshrc
    echo "source ~/.config/zsh/.aliases" >> ~/.zshrc
fi

RUNZSH=no KEEPZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
