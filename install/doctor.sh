#!/bin/bash

# Report drift between this repo and the machine.
set -u

CUR_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(dirname "$CUR_DIR")"
cd "$REPO_DIR"

OK=0
BAD=0

pass() {
    printf '\033[32m%-8s\033[0m %s\n' "ok" "$1"
    OK=$((OK + 1))
}

fail() {
    printf '\033[31m%-8s\033[0m %s\n' "$1" "$2"
    BAD=$((BAD + 1))
}

check_link() {
    local src="$1" target="$2"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ]; then
        pass "$target"
    elif [ -e "$target" ]; then
        fail "drift" "$target does not link to $src"
    else
        fail "missing" "$target"
    fi
}

check_copy() {
    local src="$1" target="$2"
    if [ ! -e "$target" ]; then
        fail "missing" "$target"
    elif diff -q "$src" "$target" > /dev/null 2>&1; then
        pass "$target"
    else
        fail "stale" "$target differs from $src"
    fi
}

echo "== config symlinks =="
for file in $(find config -type f); do
    if [[ "$file" == config/_home/* ]]; then
        target="$HOME/${file#config/_home/}"
    else
        target="$HOME/.$file"
    fi
    check_link "$file" "$target"
done

echo "== claude skill symlinks =="
for dir in claude/plugins/ship/skills/*/; do
    check_link "${dir%/}" "$HOME/.claude/skills/$(basename "$dir")"
done

echo "== script symlinks =="
for file in scripts/*; do
    name="$(basename "$file")"
    case "$name" in
        backup|backup_gdrive|restore) continue ;;
    esac
    check_link "$file" "/usr/local/lib/march/$name"
done
check_link scripts/timer "$HOME/.local/bin/timer"
check_link scripts/hyprwhspr-speaker "$HOME/.local/bin/hyprwhspr-speaker"

echo "== installed backup copies =="
for name in backup backup_gdrive restore; do
    check_copy "scripts/$name" "/usr/local/lib/march/$name"
done
for unit in systemd/backup*.service systemd/backup*.timer; do
    check_copy "$unit" "/etc/systemd/system/$(basename "$unit")"
done

echo "== sounds =="
for file in sounds/*; do
    check_link "$file" "$HOME/.local/share/sounds/$(basename "$file")"
done

echo "== keymap and branding =="
check_link install/keymap.keyd.conf /etc/keyd/default.conf
check_link branding/about.txt "$HOME/.config/omarchy/branding/about.txt"

echo "== dangling march links =="
for file in /usr/local/lib/march/* "$HOME/.claude/skills"/*; do
    if [ -L "$file" ] && [ ! -e "$file" ]; then
        fail "dangling" "$file"
    fi
done

echo
echo "$OK ok, $BAD problems"
[ "$BAD" -eq 0 ]
