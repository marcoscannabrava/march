#!/usr/bin/env bash
# Regression checks for the pstack plugin layout (CHANGES 0.9.7-0.9.13).
#
# Claude Code renders a plugin's commands AND its user-invocable skills in the
# slash menu, so a command trampoline paired with a same-named skill shows the
# entry twice (#22). 0.9.13 moved the trampolines to .codex-plugin/prompts/,
# where only the Codex symlink path reads them. The invariant here keeps a
# future upstream sync from reintroducing plugins/pstack/commands/.
#
# This also enforces the static maintenance invariants: the
# principle-* leaf flags, version parity across the three manifests, and the
# absence of model slugs in skill bodies. The
# static checks need no CLI; only the behavioral leg below does.
#
# Manual test: the behavioral leg needs the claude CLI and API access; one haiku call.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

note() { printf '%s\n' "$*"; }

# Static invariant (0.9.13, #22): the Claude Code plugin ships no commands/.
# Every /pstack:<name> is served by the skill itself; a commands/ directory
# reappearing (typically via an upstream sync) duplicates every slash-menu row.
if [ -e "$repo/plugins/pstack/commands" ]; then
  note "FAIL: plugins/pstack/commands/ exists; trampolines belong in .codex-plugin/prompts/"
  fail=1
else
  note "ok: no plugins/pstack/commands/ directory"
fi

# Codex prompts are the relocated trampolines; each must still point at a real skill.
orphan=""
for cmd in "$repo"/plugins/pstack/.codex-plugin/prompts/*.md; do
  skill="$repo/plugins/pstack/skills/$(basename "$cmd" .md)/SKILL.md"
  [ -f "$skill" ] || orphan="$orphan$cmd"$'\n'
done
if [ -n "$orphan" ]; then
  note "FAIL: Codex prompts without a matching skill:"
  note "$orphan"
  fail=1
else
  note "ok: every Codex prompt has a matching skill"
fi

# Flag invariant (CHANGES 0.9.8): no skill may carry disable-model-invocation —
# on a skill the flag makes the Skill tool refuse the invocation outright, which
# breaks the SessionStart mandate and model-initiated entry. Frontmatter only:
# skill bodies may mention the flag in prose.
flagged=""
for skill in "$repo"/plugins/pstack/skills/*/SKILL.md; do
  if sed -n '2,/^---$/p' "$skill" | grep -q '^disable-model-invocation: true$'; then
    flagged="$flagged$skill"$'\n'
  fi
done
if [ -n "$flagged" ]; then
  note "FAIL: skills must not carry 'disable-model-invocation: true':"
  note "$flagged"
  fail=1
else
  note "ok: no skill carries disable-model-invocation: true"
fi

# Principle invariant (CHANGES 0.9.9): every command-less principle-* leaf carries
# user-invocable: false (hidden from the / menu, read by path from poteto-mode) and
# NOT disable-model-invocation (the pair cancels to a dead skill).
bad_principle=""
for skill in "$repo"/plugins/pstack/skills/principle-*/SKILL.md; do
  front="$(sed -n '2,/^---$/p' "$skill")"
  printf '%s\n' "$front" | grep -q '^user-invocable: false$' || bad_principle="$bad_principle$skill (missing user-invocable: false)"$'\n'
  printf '%s\n' "$front" | grep -q '^disable-model-invocation: true$' && bad_principle="$bad_principle$skill (still carries disable-model-invocation)"$'\n'
done
if [ -n "$bad_principle" ]; then
  note "FAIL: principle-* leaves must carry user-invocable: false and not disable-model-invocation:"
  note "$bad_principle"
  fail=1
else
  note "ok: all principle-* leaves carry user-invocable: false"
fi

# Static invariant (CHANGES maintenance note): the plugin version string is
# duplicated across three manifests and must move together on a bump.
verof() { { grep -m1 '"version"' "$1" || true; } | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'; }
vc="$(verof "$repo/plugins/pstack/.claude-plugin/plugin.json")"
vx="$(verof "$repo/plugins/pstack/.codex-plugin/plugin.json")"
vm="$(verof "$repo/.claude-plugin/marketplace.json")"
if [ -n "$vc" ] && [ "$vc" = "$vx" ] && [ "$vc" = "$vm" ]; then
  note "ok: plugin version matches across the 3 manifests ($vc)"
else
  note "FAIL: plugin version differs across manifests: claude-plugin=$vc codex-plugin=$vx marketplace=$vm"
  fail=1
fi

# Static invariant: skills name no model. Every subagent runs on
# the parent session's model, so a slug in a skill body is drift.
slugs="$(grep -rnoE 'claude-(opus|fable|sonnet|haiku)[a-z0-9-]*|gpt-[0-9][a-z0-9.-]*' \
  "$repo/plugins/pstack/skills" "$repo/plugins/pstack/agents" "$repo/plugins/pstack/hooks" || true)"
if [ -n "$slugs" ]; then
  note "FAIL: skills name a model slug:"
  note "$slugs"
  fail=1
else
  note "ok: no skill names a model slug"
fi

# Behavioral leg: a command-less plugin still serves the user-typed /plugin:name
# via the skill alone. This is the assumption that lets pstack live without
# trampolines; if it fails, upstream changed slash resolution — re-read #22 and
# CHANGES 0.9.13 before reintroducing commands/. Last verified on 2.1.245.
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/.claude-plugin" "$scratch/skills/foo"
printf '%s\n' '{"name": "testplug", "version": "0.0.1", "description": "skill-only slash repro"}' \
  > "$scratch/.claude-plugin/plugin.json"
cat > "$scratch/skills/foo/SKILL.md" <<'EOF'
---
name: foo
description: skill-only slash test
---

Say exactly: SKILL-RAN
Then stop. Do not invoke any skill or tool.
EOF

out="$(claude -p --plugin-dir "$scratch" --model haiku --max-turns 3 '/testplug:foo' < /dev/null 2>&1)"
if printf '%s' "$out" | grep -q 'SKILL-RAN'; then
  note "ok: user-typed /plugin:name reaches the skill with no commands/ present"
else
  note "FAIL: /testplug:foo did not run the skill, got: $out"
  fail=1
fi

exit "$fail"
