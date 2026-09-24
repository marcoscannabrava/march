# NOTICE

This plugin is a port of upstream MIT-licensed work. All upstream copyright notices and license terms are preserved.

## Upstream sources

| Component | Upstream | Copyright | License | License file |
| --- | --- | --- | --- | --- |
| `plugins/pstack/skills/poteto-mode/`, `plugins/pstack/skills/architect/`, `plugins/pstack/skills/arena/`, `plugins/pstack/skills/how/`, `plugins/pstack/skills/interrogate/`, `plugins/pstack/skills/show-me-your-work/`, `plugins/pstack/skills/unslop/`, `plugins/pstack/skills/why/`, `plugins/pstack/skills/principle-*/`, `plugins/pstack/agents/poteto-agent.md` | [cursor/plugins/pstack @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/hooks/run-hook.cmd` (near-verbatim) | [anthropics/claude-plugins-official → superpowers @ 6.1.0](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/superpowers) (originally obra/superpowers) | (c) 2025 Jesse Vincent | MIT | [LICENSE-superpowers](LICENSE-superpowers) |
| `plugins/pstack/skills/principle-model-the-domain/` (v0.11.3 additions) | [cursor/plugins/pstack @ 3fe2823](https://github.com/cursor/plugins/tree/3fe2823ce17c1656c222d4b7c59d3f82fbf20143/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/no-comments/`, `plugins/pstack/agents/comment-sicko.md`, `plugins/pstack/skills/poteto-mode/references/bugbot-triage.md`, `plugins/pstack/skills/architect/references/design-red-flags.md` (v0.14.2 additions) | [cursor/plugins/pstack @ 4612556](https://github.com/cursor/plugins/tree/4612556/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |

## What changed in the port

The port is editorial, not mechanical.

Summary of structural changes:

- Plugin content lives at `plugins/pstack/` (with its own `.claude-plugin/plugin.json`). The repo root holds `.claude-plugin/marketplace.json` and the LICENSE / NOTICE / README docs.
- `.claude-plugin/marketplace.json` added at repo root so the repo is installable via `/plugin marketplace add`. The marketplace's single plugin entry sources from `./plugins/pstack`.
- `plugins/pstack/.codex-plugin/prompts/<name>.md` stubs added so each public skill is reachable as a slash command on Codex. Claude Code needs no stubs: the skill itself serves `/pstack:<name>`.
- `plugins/pstack/agents/comment-sicko.md` is upstream's `Comment Sicko` agent, renamed to `comment-sicko` so the name works as a Claude Code `subagent_type`. The body is verbatim.
- A Codex build shares the same `skills/` tree. It adds `plugins/pstack/.codex-plugin/plugin.json`, a root `.agents/plugins/marketplace.json`, and `plugins/pstack/skills/poteto-mode/references/codex-tools.md` (the Claude-to-Codex tool and built-in map), plus a one-line Platform note in the skills that name a Claude primitive. The skill content itself is unchanged.

## Modifications

Per the MIT license, modifications are permitted. Skill bodies have been edited to substitute Cursor-specific primitives with their Claude Code equivalents (the substitution table is in [README.md](README.md#differences-from-upstream)). All upstream copyright notices in source files (where present) are preserved.

Files authored for this port (not derived from upstream):

- `plugins/pstack/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json` (repo root)
- `plugins/pstack/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json` (repo root)
- `plugins/pstack/skills/poteto-mode/references/codex-tools.md`
- `plugins/pstack/.codex-plugin/prompts/*.md`
- `plugins/pstack/hooks/hooks.json`, `plugins/pstack/hooks/session-start`, and `plugins/pstack/hooks/session-start-context.md` (the auto-fire hook and its mandate)
- `NOTICE.md` (this file)
- `README.md`
- `LICENSE-cursor-team-kit` (copied verbatim from upstream cursor-team-kit MIT)
