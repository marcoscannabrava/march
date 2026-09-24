# pstack for Claude Code, Codex, and Prime Agent

Claude Code port of [poteto](https://x.com/poteto)'s [pstack](https://github.com/cursor/plugins/tree/main/pstack) plugin (skill tree synced against upstream `4612556`, pstack v0.14.2 — see [What's deliberately not ported](#whats-deliberately-not-ported)). The same `skills/` tree also ships as a Codex plugin (see [Running on Codex](#running-on-codex)) and is discovered as-is by [Prime Agent](https://github.com/PrimeIntellect-ai/prime-agent) (see [Prime Agent](#prime-agent)). Original by Lauren Tan; ships MIT.

> if you want to go fast, go deep first. pstack helps you write less, but higher quality code. rigorous agent workflows you can parallelize with confidence.

This is not a verbatim copy. Skill bodies have been edited so every Cursor-specific primitive resolves to its Claude Code equivalent — see [Differences from upstream](#differences-from-upstream) for the full list. License attribution lives in [NOTICE.md](NOTICE.md).

## Install

### Claude Code

This repo ships as a Claude Code marketplace containing one plugin (`pstack`).

```shell
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

From 0.9.5 the plugin auto-fires, the same way superpowers does: a `SessionStart` hook (on `startup`, `/clear`, and post-`compact`) injects a ~0.3k-token mandate that routes any non-trivial engineering task into `poteto-mode` before the first response. The full skill still loads only on invoke. Dispatched subagents are told to ignore the mandate, and explicit user instructions take precedence. To opt out, delete `hooks/hooks.json` from the installed copy (`~/.claude/plugins/cache/pstack-claude/pstack/<version>/hooks/hooks.json`); a plugin update restores it.

### Codex

The same plugin carries a `.codex-plugin/plugin.json` manifest and a root `.agents/plugins/marketplace.json`. The verified install is to link the plugin's skills into your cross-runtime skills directory:

```shell
git clone https://github.com/michael-denyer/pstack-claude
cd pstack-claude
for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done
```

Codex discovers the linked skills and namespaces them under the plugin, so they list as `pstack:poteto-mode`, `pstack:how`, and so on. The namespace comes from `plugins/pstack/.codex-plugin/plugin.json` and resolves through the flat symlinks, even though each linked skill sits one directory below that manifest (verified on a live session via this symlink install). To enable the multi-model and parallel-subagent skills (`interrogate`, `arena`, `how`, `why`, `architect`), turn on subagents in `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

For slash-command shortcuts (`/poteto-mode`, `/how`, and the rest), link the command files into Codex's prompts directory:

```shell
mkdir -p ~/.codex/prompts
for c in plugins/pstack/.codex-plugin/prompts/*.md; do ln -s "$PWD/$c" ~/.codex/prompts/"$(basename "$c")"; done
```

Each command invokes its skill, so `/how` runs the `how` skill. Installing the full plugin through the Codex marketplace (the root `.agents/plugins/marketplace.json`) carries skills and commands together; the two symlink steps above are the verified local path. Teardown is `rm ~/.agents/skills/<name>` and `rm ~/.codex/prompts/<name>.md`.

### Prime Agent

[Prime Agent](https://github.com/PrimeIntellect-ai/prime-agent) discovers skills from `~/.agents/skills/` and from `.agents/skills/` in the working tree up to the git root ([docs](https://github.com/PrimeIntellect-ai/prime-agent/blob/main/packages/coding-agent/docs/skills.md)). That is the same `~/.agents/skills/` directory the Codex install symlinks into, so the [Codex skill-link step](#codex) doubles as the Prime install — if you have already run it, Prime picks the skills up with no extra work:

```shell
git clone https://github.com/michael-denyer/pstack-claude
cd pstack-claude
for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done
```

pstack's `SKILL.md` frontmatter is a subset of what Prime reads: it requires `name` (lowercase, matching the parent directory — every pstack skill already conforms) and `description`, honours `disable-model-invocation`, and ignores unknown keys such as pstack's `user-invocable`. `curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh` installs Prime itself; `--no-skills` disables discovery, and explicit `--skill <path>` still loads. Prime is model-agnostic, so running these skills against **ChatGPT / OpenAI models is a Prime backend setting, not a plugin change** — keep the multi-model panels in `arena`, `interrogate`, `architect`, and `how` genuinely diverse across whatever models you configure (see the OpenAI panel note under [Running on Codex](#running-on-codex)).

Unverified relative to Codex: the Codex path above is confirmed on a live session; the Prime path is derived from Prime's documented discovery paths and frontmatter schema, not yet run on a live Prime session. Prime has no plugin-hook runtime, so the Claude Code auto-fire hook does not apply — enter `pstack:poteto-mode` by name or add a standing routing instruction to your Prime config. Teardown is `rm ~/.agents/skills/<name>`.

## Layout

```text
.
├── .claude-plugin/marketplace.json   # Claude Code marketplace manifest (repo root)
├── .agents/plugins/marketplace.json  # Codex marketplace manifest (repo root)
├── plugins/pstack/                   # the plugin itself
│   ├── .claude-plugin/plugin.json    # Claude Code manifest
│   ├── .codex-plugin/plugin.json     # Codex manifest (skills: ./skills/)
│   ├── skills/                       # 28 skills (shared by all three runtimes)
│   │   ├── poteto-mode/references/codex-tools.md  # Claude→Codex tool/skill map
│   ├── .codex-plugin/prompts/        # 9 slash command stubs (Codex only; link into ~/.codex/prompts)
│   ├── hooks/                        # SessionStart auto-fire: injects the poteto-mode mandate (Claude Code only)
│   └── agents/                       # Claude subagents: poteto-agent, comment-sicko (Codex routes via codex-tools.md)
├── tests/skill-collision-repro.sh    # layout, flag, version, and no-slug invariants (needs claude CLI)
├── LICENSE                           # pstack upstream MIT
├── LICENSE-cursor-team-kit           # cursor-team-kit upstream MIT
├── LICENSE-superpowers               # superpowers upstream MIT (hook runner)
├── NOTICE.md                         # attribution table
└── README.md                         # this file
```

Plugin-internal path references in the docs below (`skills/<name>/`, `.codex-plugin/prompts/<name>.md`) are relative to `plugins/pstack/`.

## Running on Codex

The Codex build shares one `skills/` tree with the Claude Code build. Nothing is forked or generated. One mapping file does the translation. That single-mapping-file spine is the one `superpowers` ships for Codex. pstack diverges in one respect. superpowers writes its skills in tool-neutral language, so no skill names a runtime tool. pstack keeps the upstream Claude-native prose and adds a one-line Platform note to each skill that names a Claude primitive, so the port stays in lockstep with upstream sync.

- **Skill invocation.** Codex loads `SKILL.md` natively. There is no `Skill` tool. You invoke a skill by name (ask for it, or pick `pstack:poteto-mode` from the list).
- **Commands.** The 9 `.codex-plugin/prompts/*.md` files are Codex-only. Codex reads their `description` frontmatter and the filename, ignores the keys it doesn't know, and each body invokes its skill. Link them into `~/.codex/prompts/` for `/name` shortcuts (see [Install on Codex](#codex)). Claude Code ships no `commands/` directory: it renders both commands and user-invocable skills in the slash menu, so a trampoline paired with its skill duplicated every `/pstack:<name>` row. The skill alone serves the slash command there.
- **Tool and built-in mapping.** When a skill names a Claude tool (the `Agent` tool, `AskUserQuestion`) or a Claude built-in skill (`run`, `verify`, `loop`, `plugin-dev:skill-development`), it resolves through [`skills/poteto-mode/references/codex-tools.md`](plugins/pstack/skills/poteto-mode/references/codex-tools.md). `poteto-mode` and every skill that names one of those carries a one-line **Platform note** pointing there.
- **Subagents.** The `Agent` tool maps to Codex `spawn_agent` / `wait_agent` / `close_agent`, enabled by `multi_agent = true`. Parallel fan-out is multiple `spawn_agent` calls in one turn. Without the flag, `interrogate`, `arena`, `how`, `why`, and `architect` degrade to a single sequential pass. There is no `poteto-agent` subagent type on Codex; route ad-hoc subagents by dispatching a `spawn_agent` told to read `poteto-mode` first.
- **Auto-fire.** The `hooks/` SessionStart injection is Claude Code-only; Codex has no plugin hook runtime. Enter `pstack:poteto-mode` by name, or add a standing instruction to `~/.codex/AGENTS.md` if you want the same always-on routing.
- **Models.** Skills name no model. Every subagent runs on the parent session's model, on Claude Code and Codex alike.

Verified on a live Codex session installed via the symlinks: the user-facing skills are discovered and namespaced under `pstack` (`pstack:poteto-mode`, `pstack:interrogate`, and so on). The `principle-*` leaf skills carry `user-invocable: false` and no command, so Codex does not surface them in the picker, the same as Claude Code. They stay installed for `poteto-mode` to read by path. The deeper behaviors (mapping resolution mid-task, `spawn_agent` fan-out) follow the proven `superpowers` pattern and are worth confirming in your own session.

## Dependencies

Nothing is declared in `plugin.json`. Install the one companion plugin yourself:

- **`plugin-dev`** (from the `claude-plugins-official` marketplace) — the rewiring routes skill-authoring tasks (in `poteto-mode`) to the `plugin-dev:skill-development` skill:

  ```shell
  /plugin marketplace add anthropics/claude-plugins-official
  /plugin install plugin-dev@claude-plugins-official
  ```

  Until 0.9.2 this was a `dependencies` entry in `plugin.json`. The desktop app's `--plugin-dir` load mode can never resolve cross-marketplace dependencies and hard-disables the whole plugin, so 0.9.3 removed the declaration. Without `plugin-dev` installed, only the skill-authoring routes degrade; everything else works.

Not declared as deps, but referenced in skill bodies:

- **`run`, `verify`, `loop`** — Claude Code CLI built-ins (ship with the binary, always available).
- **`gh` CLI** — used by the Opening a PR playbook and the `why` source-control investigator. Install via [`brew install gh`](https://cli.github.com) and authenticate with `gh auth login`.

No third-party plugins.

## Slash commands

| command | use it when |
| --- | --- |
| `/poteto-mode` | default entry point for any non-trivial task |
| `/how` | walk through how a subsystem works |
| `/why` | investigate why something was built this way (parallel multi-MCP evidence) |
| `/architect` | settle types and module shape before writing code that crosses a function boundary |
| `/arena` | run N parallel attempts at the same task and pick the best parts |
| `/interrogate` | have four independent reviewers try to break a diff |
| `/show-me-your-work` | log decisions to a reviewable tsv decision trail |
| `/unslop` | clean up writing by removing AI tells |
| `/no-comments` | strip comments before review via the `comment-sicko` subagent, then fix what it finds |

## Subagents

`poteto-agent` ships unchanged. Spawn from a parent with `subagent_type: "poteto-agent"`.

`comment-sicko` is the read-only comment reviewer the `no-comments` skill spawns. Upstream names it `Comment Sicko`; the port renames it to `comment-sicko` so the name is a valid `subagent_type`. Invoke it through `/no-comments`, not directly.

## Differences from upstream

The port is editorial, not mechanical. Anywhere upstream pstack assumed Cursor-specific primitives, this port substitutes the Claude Code equivalent so refs actually resolve. Two prior ports ([v1truv1us/ai-eng-system](https://github.com/v1truv1us/ai-eng-system), [Evan-Kim2028/agent-fleet](https://github.com/Evan-Kim2028/agent-fleet)) stop at namespacing — they vendor pstack under `pstack/` and leave the Cursor refs intact. This port does the content surgery.

### What's substituted in skill bodies

| Upstream (Cursor) | This port (Claude Code) |
| --- | --- |
| `Task` tool, `subagent_type: generalPurpose`, `readonly: false/true` | `Agent` tool, `subagent_type: "general-purpose"`, no readonly flag (subagent_type controls MCP access) |
| `AskQuestion` tool | `AskUserQuestion` tool |
| Cursor's built-in `/loop` | Claude Code's built-in `loop` skill |
| Cursor's built-in `/create-skill` | `plugin-dev:skill-development` skill |
| `cursor-team-kit` `control-cli` (CLI/TUI driver) | Claude Code's `run` skill |
| `cursor-team-kit` `control-ui` (browser/Electron driver) | Claude Code's `verify` skill |
| Transcripts at `~/.cursor/projects/*/` or `agent-transcripts/` | `~/.claude/projects/<encoded-cwd>/*.jsonl` (where `<encoded-cwd>` is the workspace cwd with `/` → `-`) |
| Skill paths `.cursor/skills/`, `~/.cursor/plugins/` | `.claude/skills/`, `~/.claude/plugins/` |
| MCP discovery via Cursor's `mcps/` directory | Tool list at top of system prompt (`mcp__<server>__<name>` entries), or `.mcp.json`, or `claude mcp list` |
| Cursor cloud agents (`environment: "cloud"`, `cloud_base_branch`) | Local background subagents (`run_in_background: true`), isolated by git worktree |

### What's lost in translation

**Model diversity.** Upstream's panels (`arena`, `interrogate`, `architect`, `how` critics) run four different model families. This fork names no model, so every panel member runs on the parent session's model. Independence comes from separate runs, not separate models.

### What's deliberately kept

- The `poteto-agent` subagent ID and all references to it.
- `run_in_background: true` on Agent calls (Claude Code supports it).
- `/loop` slash references in skill bodies — resolves in Claude Code now.
- The principle/playbook structure and every word of the principles themselves.

### What's deliberately not ported

- **`automations/benny/`** (upstream `0452e08`, the only pstack change between `e46364b` and v0.10.0) — a dormant Slack issue-triage and reproduce-and-fix automation pack built on Cursor's event-triggered automations. It registers no slash skills even upstream, so excluding it changes nothing about the ported plugin's behavior. Porting it would mean translating Cursor's event-trigger runtime to Claude Code's polling-based scheduled agents plus Slack and tracker plumbing — speculative infrastructure with no local user. Revisit if an unattended issue-intake stream materialises; the likely first step is porting the triage skill onto a single Claude scheduled agent, not the whole pack.
- **`docs/guide/`** (upstream `02c03a9`, `0b7ef5b`, `424829e`) — the ten-chapter usage tutorial and its six screenshots (2.3 MB). It teaches pstack through Cursor's UI, sticky mode, and cloud agents, so a faithful port would be a rewrite rather than a sync, and none of it ships as skill content. Read it upstream at [cursor/plugins/pstack/docs/guide](https://github.com/cursor/plugins/tree/main/pstack/docs/guide); the concepts map through the substitution table above. Revisit if the port grows its own tutorial.
- **Sticky mode** (upstream `#144`) — Cursor-only `mode`/`icon`/`color`/`reminder` frontmatter with no Claude Code equivalent. The port's 0.9.5 SessionStart hook is the analog and already carries the non-trivial / trivial / opt-out logic.
- **`is_background: true` on `poteto-agent`** (upstream `99559f2`) — Cursor subagent frontmatter. Claude Code's agent frontmatter has no such key, and `run_in_background: true` on the spawning `Agent` call already covers it.
- **`cursor-team-kit` beyond the seven imported skills** — the rest either duplicate Claude Code built-ins (`verify-this` → the `verify` skill and built-in verification discipline; `check-compiler-errors` → LSP diagnostics; `control-cli`/`control-ui` → `run`/`verify`, already the substitution targets) or overlap skills and playbooks this port ships (`loop-on-ci`, `review-and-ship`, `weekly-review` vs the Opening a PR playbook). `pr-review-canvas` is Cursor-UI-specific.

### Forking note

Editing skill bodies forks this from upstream. Re-syncing to a future pstack release means re-applying the substitution table.

## License

MIT. Three upstream LICENSE files are preserved:

- [LICENSE](LICENSE) — pstack (Lauren Tan)
- [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) — Cursor
- [LICENSE-superpowers](LICENSE-superpowers) — superpowers, Jesse Vincent (covers the vendored `hooks/run-hook.cmd`)
