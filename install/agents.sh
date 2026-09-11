#!/bin/bash

# Wire the vendored pstack plugin (agents/pstack-claude) into claude, codex, and pi.
# Idempotent: re-running reports "already" / skips and changes nothing.

CUR_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(dirname "$CUR_DIR")"

if [ -f "$REPO_DIR/utils.sh" ]; then source "$REPO_DIR/utils.sh";
else echo "utils.sh not found."; exit 1; fi

PSTACK_DIR="$REPO_DIR/agents/pstack-claude"
PSTACK_SKILLS="$PSTACK_DIR/plugins/pstack/skills"

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

if [ ! -d "$PSTACK_SKILLS" ]; then
    log_red "$PSTACK_SKILLS not found — vendor pstack first (see agents/pstack-claude/UPSTREAM.md)."
    exit 1
fi

log_purple "######### claude #########"
if ! command -v claude &> /dev/null; then
    log_yellow "claude not installed, skipping."
else
    marketplaces="$(claude plugin marketplace list 2>/dev/null)"
    if echo "$marketplaces" | grep -q "pstack-claude" && echo "$marketplaces" | grep -qF "$PSTACK_DIR"; then
        log_yellow "claude marketplace pstack-claude already points at $PSTACK_DIR."
    else
        claude plugin marketplace remove pstack-claude &> /dev/null
        claude plugin marketplace add "$PSTACK_DIR" && log_green "claude marketplace pstack-claude added from $PSTACK_DIR."
    fi

    if claude plugin list 2>/dev/null | grep -q "pstack@pstack-claude"; then
        log_yellow "claude plugin pstack@pstack-claude already installed."
    else
        claude plugin install pstack@pstack-claude && log_green "claude plugin pstack@pstack-claude installed."
    fi
fi

log_purple "######### codex ##########"
if ! command -v codex &> /dev/null; then
    log_yellow "codex not installed, skipping."
else
    if codex plugin marketplace list 2>/dev/null | grep "pstack-claude" | grep -qF "$PSTACK_DIR"; then
        log_yellow "codex marketplace pstack-claude already points at $PSTACK_DIR."
    else
        codex plugin marketplace remove pstack-claude &> /dev/null
        codex plugin marketplace add "$PSTACK_DIR" && log_green "codex marketplace pstack-claude added from $PSTACK_DIR."
    fi

    if codex plugin list 2>/dev/null | grep "pstack@pstack-claude" | grep -q "installed"; then
        log_yellow "codex plugin pstack@pstack-claude already installed."
    else
        codex plugin add pstack@pstack-claude && log_green "codex plugin pstack@pstack-claude installed."
    fi
fi

log_purple "########## pi ############"
ensure_link "$PSTACK_SKILLS" "$HOME/.pi/agent/skills/pstack"

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
