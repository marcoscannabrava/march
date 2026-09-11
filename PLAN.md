# PLAN: pstack across claude, codex, and pi

[pstack](https://github.com/michael-denyer/pstack-claude) (~50 workflow skills: `why`, `how`,
`interrogate`, `swarm`, `arena`, `deslop`, …) is currently a Claude-only plugin, installed from a
git marketplace that Claude cloned into `~/.claude/plugins/`. Nothing outside Claude sees it, and
the repo is not its source of truth.

Goal: vendor pstack in this repo once, and have `install.sh` wire it natively into all three
agents. The repo becomes the single source of truth; each agent's own plugin/skill mechanism
consumes it.

## Current state (verified on this machine)

- pstack 0.9.13, upstream commit `c42e947d`, installed for Claude via marketplace
  `pstack-claude` (git source, cloned to `~/.claude/plugins/marketplaces/pstack-claude`).
- The repo already carries the Claude side of the declaration:
  `config/_home/.claude/settings.json` (`enabledPlugins: pstack@pstack-claude`),
  `config/_home/.claude/plugins/installed_plugins.json`, and
  `config/_home/.claude/pstack-models.md` (per-role model overrides).
- The plugin is already cross-runtime aware: every SKILL.md has a "Platform note" for
  non-Claude runtimes pointing at `skills/poteto-mode/references/codex-tools.md`, no skill
  references `${CLAUDE_PLUGIN_ROOT}`, and it ships manifests for all three worlds:
  `.claude-plugin/marketplace.json` (Claude), `.agents/plugins/marketplace.json` with
  `products: ["CODEX"]` (Codex), `.codex-plugin/` with 31 prompt files.
- Codex 0.154 has a native plugin system: `codex plugin marketplace add <local path|git>` +
  `codex plugin add`. `~/.codex/config.toml` is already symlinked into this repo.
- Pi 0.85 discovers skills in `~/.pi/agent/skills/` recursively and **follows symlinked
  directories** (verified in `dist/core/skills.js`). Pi's docs also bless a `skills` array in
  `settings.json` pointing at other harnesses' skill dirs.
- Claude CLI supports local marketplaces: `claude plugin marketplace add <path>`.

## Decision: vendor in repo + native wiring (not "look in claude's folder", not "replicate")

| Option | Verdict |
|---|---|
| **A. Pi/codex point into `~/.claude/plugins/...`** | Rejected. The cache path embeds the version (`cache/pstack-claude/pstack/0.9.13/...`), so every pstack update silently breaks the other agents. Claude owns that directory's lifecycle (uninstall/update wipes it). And the repo still wouldn't be the source of truth. |
| **B. Replicate a copy per agent** | Rejected. Three copies drift; every update is a triple manual sync; no single truth. |
| **C. Vendor once in the repo, wire each agent natively** (chosen) | One canonical copy, one update procedure. Claude and Codex consume it through their native marketplace systems (which keep derived caches — declared and rebuildable). Pi consumes it through one symlink — zero copies, live immediately. |

Symlinks and plugin caches are not "replication" in the bad sense: the vendored copy is the only
source; caches are derived artifacts that each harness rebuilds on command.

## Target layout

```
agents/pstack-claude/                  # vendored upstream repo @ c42e947d (v0.9.13), .git removed
  .claude-plugin/marketplace.json      #   Claude marketplace manifest (as upstream)
  .agents/plugins/marketplace.json     #   Codex marketplace manifest (as upstream)
  plugins/pstack/
    .claude-plugin/plugin.json
    .codex-plugin/{plugin.json,prompts/*.md}
    agents/*.md                        #   Claude-only subagents (poteto-agent, comment-sicko)
    hooks/                             #   Claude-only SessionStart hook
    skills/*/SKILL.md                  #   the actual payload, shared by all three
  LICENSE  NOTICE.md  README.md  …
  UPSTREAM.md                          #   NEW: source repo, pinned commit, version, update steps
config/_home/.claude/plugins/known_marketplaces.json   # MOVED into repo; pstack source → local path
install/agents.sh                      # NEW: the wiring, run by ./install.sh -a
```

The vendored copy is kept **pristine** (byte-identical to upstream at the pinned commit) so updates
are a clean overwrite. Any pi-specific adaptation we later want goes through upstream or a separate
overlay, never by patching the vendored tree.

## Wiring per agent

### Claude — switch the existing marketplace from git to the local vendored path

1. Move `~/.claude/plugins/known_marketplaces.json` into the repo at
   `config/_home/.claude/plugins/known_marketplaces.json` (install.sh links it like the rest of
   `config/_home`). This file is the declaration of record for all three marketplaces.
2. Repoint pstack's marketplace at the repo:
   `claude plugin marketplace remove pstack-claude`,
   `claude plugin marketplace add "$REPO_DIR/agents/pstack-claude"`,
   `claude plugin install pstack@pstack-claude`.
   Claude rewrites `known_marketplaces.json` itself; since it's a symlink into the repo, the new
   local-source entry lands in git automatically. Commit the result.
3. Result: same plugin, same version, skills/hooks/agents/commands all keep working; the declared
   source is now the repo. Claude still caches the plugin by version — that cache is derived.
   After bumping the vendored copy: `claude plugin update pstack@pstack-claude`.
4. `~/.claude/pstack-models.md` already symlinks into the repo. Unchanged.

### Codex — native plugin install from the local marketplace

```sh
codex plugin marketplace add "$REPO_DIR/agents/pstack-claude"   # reads .agents/plugins/marketplace.json
codex plugin add pstack@pstack-claude                           # skills + .codex-plugin/prompts
```

This uses upstream's own Codex port (shared skills, `codex-tools.md` tool mapping, prompt files
becoming slash commands). Verify during implementation where Codex runs it from (in place vs
cache) and where it persists the marketplace source; if it caches, the refresh after an update is
`codex plugin remove pstack && codex plugin add pstack@pstack-claude`.

### Pi — one symlink into `~/.pi/agent/skills/`

```sh
ensure_link "$REPO_DIR/agents/pstack-claude/plugins/pstack/skills" "$HOME/.pi/agent/skills/pstack"
```

Pi's loader recurses through symlinked dirs (verified in source), so all ~50 skills appear, loaded
on demand, invocable as `/skill:why` etc. Edits are live immediately. The skills' "Platform note"
tells the model to resolve Claude tool names via `codex-tools.md` — good enough for pi too; no
pi-specific mapping for now. Skill names (`why`, `how`, `tdd`, …) don't collide with the existing
pi skills (`diagnose-crash`, `omarchy`, `council-mode`, `pi-subagents`); pi keeps the first on
collision and warns, so doctor + a manual glance after install cover this.

What pi/codex intentionally do **not** get: the Claude-only SessionStart hook (poteto-mode mandate
injection) and the two Claude subagent definitions. No equivalents exist there; the skills degrade
gracefully without them.

## install.sh / doctor.sh changes

- New flag `./install.sh -a` (`--agents`) → runs `install/agents.sh`. Update `usage()` and the
  README example. No sudo anywhere in this step.
- `install/agents.sh`, following repo conventions (source `utils.sh`, `ensure_link`, `log_*`,
  idempotent, guard each CLI with `command -v` and `log_yellow` a skip when absent):
  1. Assert `agents/pstack-claude/plugins/pstack/skills` exists, else `log_red` and stop the step.
  2. Claude: if `claude plugin marketplace list` lacks pstack-claude or its root ≠ `$REPO_DIR`,
     re-add as above; ensure `pstack@pstack-claude` installed.
  3. Codex: `codex plugin marketplace list`/`codex plugin list` greps → add marketplace / plugin
     only when missing.
  4. Pi: the `ensure_link` line above.
  5. Cleanup of pre-existing drift (one-time, logged): remove the 17 dangling symlinks in
     `~/.claude/skills/` that point into the deleted `claude/` tree (targets under
     `$REPO_DIR/claude` that no longer exists — nothing else touches them).
- `install/doctor.sh`:
  - **Delete the stale `claude/plugins/ship/skills/*/` loop** — that tree was removed in 4232bf0
    and every line of it fails today.
  - Add `check_link agents/pstack-claude/plugins/pstack/skills ~/.pi/agent/skills/pstack`.
  - Add `check_link config/_home/.claude/plugins/known_marketplaces.json ~/.claude/plugins/known_marketplaces.json`
    (after the move) and grep that its pstack entry points at `$REPO_DIR` (catches a moved checkout).
  - Add best-effort CLI probes, guarded by `command -v`: `claude plugin list` shows pstack
    installed; `codex plugin list` shows `pstack@pstack-claude` installed.
  - The existing "dangling march links" check stays and goes green after step 5 above.
- `.gitignore`: drop the three stale `claude/plugins/ship/...` playwright lines.
- README: replace the `claude/` layout row with `agents/`, document `./install.sh -a` and the
  update procedure below. CLAUDE.md: update the stale "-s symlinks … and the Claude skills" line,
  add a reload-note row (pi: live; claude: `claude plugin update`; codex: re-add).

## Updating pstack later

1. `git clone --depth 1 --branch <tag> https://github.com/michael-denyer/pstack-claude.git /tmp/pstack`
2. `rsync -a --delete --exclude=.git /tmp/pstack/ agents/pstack-claude/`
3. Edit `agents/pstack-claude/UPSTREAM.md` (new commit/version/date), review `CHANGES.md`, commit.
4. Refresh derived caches: `claude plugin update pstack@pstack-claude`; re-add for codex if it
   caches; pi is live already.

## Execution order

1. Vendor: copy the existing local clone (`~/.claude/plugins/marketplaces/pstack-claude`, already
   at exactly the pinned `c42e947d`) minus `.git` into `agents/pstack-claude/`; add `UPSTREAM.md`.
2. Claude migration: move `known_marketplaces.json` into `config/_home/.claude/plugins/`, re-add
   the marketplace from the repo path, reinstall pstack, commit the rewritten JSON.
3. Codex wiring: `codex plugin marketplace add` + `codex plugin add`.
4. Pi wiring: the symlink.
5. `install/agents.sh` + `-a` flag encoding steps 2–4 idempotently.
6. doctor.sh / .gitignore / README / CLAUDE.md updates + dangling-link cleanup.
7. Verify (below), then commit.

## Verification

- `./install/doctor.sh` green; `bash -n install.sh install/agents.sh`.
- Re-run `./install.sh -a`: every step reports "already" / skips — no changes.
- Claude: `claude plugin marketplace list` shows pstack-claude rooted at the repo; new session
  starts with the poteto-mode context (SessionStart hook); `/plugin` shows pstack enabled.
- Codex: `codex plugin list` shows `pstack@pstack-claude` installed; a pstack skill/prompt is
  visible in a new session.
- Pi: `/skill:why` loads the vendored `why/SKILL.md`; the skills list shows the pstack set.
- Cross-check one skill (`why`) renders identically in all three.

## Risks / notes

- **Checkout path is baked in** to `known_marketplaces.json` and Codex's marketplace config.
  Moving the checkout requires `./install.sh -a` again — same as every other absolute symlink this
  repo manages.
- **Liveness differs by harness**: pi is instant; claude/codex may cache and need the refresh
  commands after an update. Documented in README so nobody edits the vendored tree expecting magic.
- **Third-party trust**: vendoring pins us to `c42e947d`; we no longer track upstream updates
  automatically. That's the point (source of truth), but updates are now a deliberate act.
- `known_marketplaces.json` carries `lastUpdated` timestamps that Claude rewrites — occasional git
  noise, same trade-off already accepted for `installed_plugins.json`.
- Out of scope: resurrecting the removed `claude/ship` skills (their deletion in 4232bf0 stands —
  this plan only cleans up their dangling links and stale references).

## Optional follow-ups (not in the first pass)

- `config/_home/.codex/pstack-models.md`: a Codex-slug model-override sheet per the `setup-pstack`
  skill's Codex guidance (loaded via `~/.codex/AGENTS.md`). Skills fall back to inline defaults
  without it.
- A `pi-tools.md` reference mapping pi's tool/subagent names, contributed upstream rather than
  patched into the vendored tree.
