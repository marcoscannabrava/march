
ZSH=$HOME/.oh-my-zsh

# ZSH theme and plugins
ZSH_THEME="simple"

plugins=(
  git
  gitfast
  last-working-dir
  zsh-syntax-highlighting
  history-substring-search
  colored-man-pages
  docker docker-compose
  fzf
)

export FZF_BASE=/usr/bin/fzf

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
# unalias rm # No interactive rm by default (brought by plugins/common-aliases)

# Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Rails, Ruby, NodeJs uses the local `bin` folder to store binstubs.
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# load user ~/.aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export BUNDLER_EDITOR="code"

# Go binaries
export PATH=$PATH:/usr/local/go/bin

# devcontainer - needs to be installed in vscode
export PATH=$PATH:/home/marcos/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin

# opencode
export PATH=/home/marcos/.opencode/bin:$PATH

# Autocomplete for Terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# ------- Package/Version Managers -------

# nvm - Node Version Manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# ------- END Package/Version Managers -------


# ------------ ZSH load hook --------------- #
# Load .workspace file if it exists in a directory when zsh is loaded or when cd'ing
# the file's first line needs the magic string
function load_workspace() {
  if [ -f .workspace ] && [ "`head -1 .workspace`" = "# m4s runs-on-open: true" ]; then
    source .workspace
  fi
}
load_workspace

function cd_func() {
  builtin cd "$@"
  load_workspace
}
alias cd="cd_func"


# requires installing cmake manually in ~/apps/
if [ -d "$HOME/apps/cmake-4.0.2-linux-x86_64/bin" ]; then
  export PATH=$PATH:$HOME/apps/cmake-4.0.2-linux-x86_64/bin
fi

# requires installing emscripten manually in ~/apps/
if [ -d "$HOME/apps/emsdk" ]; then
  export EMSDK_QUIET=1; source "/home/marcos/apps/emsdk/emsdk_env.sh"
fi
