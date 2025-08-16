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

    cp -a -- "$src" "$dest" && \
    log_green "'$src' backed up." || \
    (log_red "Failed to backup '$src'."; return 1)
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
