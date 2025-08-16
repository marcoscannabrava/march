# ANSI escape codes
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

# Background colors
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"


function log_purple() {
    echo -e "${BOLD}${MAGENTA}$1${RESET}"
}

function log_green() {
    echo -e "${BOLD}${GREEN}$1${RESET}"
}

function log_yellow() {
    echo -e "${BOLD}${YELLOW}$1${RESET}"
}

function log_red() {
    echo -e "${BOLD}${RED}$1${RESET}"
}


function log_blue_on_yellow() {
    echo -e "${BOLD}${BLUE}${BG_YELLOW}$1${RESET}"
}

function backup() {
    local src="$1"
    local dest="${2:-${src}.bkp}"
    if [[ -z "$src" ]]; then log_red "No source file specified for backup."; return 1; fi

    mv "$src" "$dest" && \
    log_green "'$src' backed up." || \
    (log_red "Failed to backup '$src'."; return 1)
}

function config_pacman() {
    if [ ! -f /etc/pacman.conf.bkp ]; then
        sudo cp /etc/pacman.conf /etc/pacman.conf.bkp
        sudo sed -i "/^#Color/c\Color\nILoveCandy
        /^#VerbosePkgLists/c\VerbosePkgLists
        /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
        sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
        log_green "pacman configured successfully."
        return 0
    fi
    log_yellow "pacman already configured."
}

cat <<EOF
                   ▂
                  ▟█▙
                 ▟███▙
                ▟█████▙
               ▟███████▙
              ▂▔▀▜██████▙
             ▟██▅▂▝▜█████▙
            ▟█████████████▙
           ▟███████████████▙
          ▟█████████████████▙
         ▟███████████████████▙
        ▟█████████▛▀▀▜████████▙
       ▟████████▛      ▜███████▙
      ▟█████████        ████████▙
     ▟██████████        █████▆▅▄▃▂
    ▟██████████▛        ▜█████████▙
   ▟██████▀▀▀              ▀▀██████▙
  ▟███▀▘                       ▝▀███▙
 ▟▛▀                               ▀▜▙

                 mArch
            Arch + Hyprland
            ===============
EOF
