#!/bin/bash

# Claude Code passes session JSON on stdin.
input=$(cat)

IFS=$'\t' read -r model effort thinking used cwd < <(jq -r '[
    .model.display_name // "?",
    .effort.level // "-",
    (.thinking.enabled // false),
    (.context_window.used_percentage // 0 | floor),
    .workspace.current_dir // .cwd
] | @tsv' <<< "$input")

[ "$thinking" = "true" ] && effort="$effort +think"

printf '%s · %s · %s%% ctx · %s' "$model" "$effort" "$used" "${cwd/#$HOME/\~}"
