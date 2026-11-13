#!/bin/bash

# Link own skills into every agent.
# Targets: claude, codex, and ~/.agents (pi).
# Idempotent: re-running reports "already" / skips and changes nothing.

CUR_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(dirname "$CUR_DIR")"

if [ -f "$REPO_DIR/utils.sh" ]; then source "$REPO_DIR/utils.sh";
else echo "utils.sh not found."; exit 1; fi

# Same converge-to-link pattern as install.sh (no sudo needed here).
function ensure_link() {
    local src="$1"
    local target="$2"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        log_yellow "$target already linked."
        return 0
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup "$target" || return 1
    fi

    mkdir -p "$(dirname "$target")"
    ln -sfn "$src" "$target"
    log_green "linked: $target"
}

log_purple "##### own skills #########"
SKILL_DIRS=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills")
for skill in "$REPO_DIR"/agents/skills/*/; do
    skill="${skill%/}"
    for dir in "${SKILL_DIRS[@]}"; do
        ensure_link "$skill" "$dir/$(basename "$skill")"
    done
done

log_purple "###### stale cleanup #####"
# One-time: drop symlinks into the claude/ tree removed in 4232bf0.
if [ -d "$HOME/.claude/skills" ]; then
    for link in "$HOME/.claude/skills"/*; do
        [ -L "$link" ] || continue
        if [[ "$(readlink "$link")" == "$REPO_DIR/claude/"* ]] && [ ! -e "$link" ]; then
            rm -f "$link"
            log_green "removed dangling link: $link"
        fi
    done
fi
