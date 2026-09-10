source ~/.config/zsh/.zshrc
source ~/.config/zsh/.aliases

# Google Cloud SDK: PATH and shell completion
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Pi
export PATH="/home/marcos/.local/share/pi-node/node-v22.23.2-linux-x64/bin:$PATH"
