# dotfiles for a very nice (m)arch

> thanks Omarchy for all the quality of life improvements

```sh
# this install omarchy base
./install.sh -o

# this install customizations
./install.sh -pswk

```

# claude code config

`~/.claude` config lives in `config/_home/.claude/` and is symlinked by `./install.sh -s`:

| File | Notes |
|---|---|
| `CLAUDE.md` | global instructions; `@`-includes `pstack-models.md` |
| `pstack-models.md` | per-role model overrides for pstack skills |
| `settings.json` | permissions, hooks, model, enabled plugins, marketplaces |
| `plugins/installed_plugins.json` | pinned plugin versions/SHAs |

`.credentials.json` holds an OAuth token and is deliberately **not** versioned (see `.gitignore`).

Skills live in `claude/plugins/ship/skills/` (the `mc-skills` marketplace, plugin `ship`) and are
symlinked into `~/.claude/skills/` by the same `-s` flag — see [claude/README.md](claude/README.md).

Claude Code rewrites `settings.json` (auto-mode environment notes) and
`installed_plugins.json` (on plugin updates) in place. Because they are symlinks into this repo,
those writes show up as uncommitted changes — review before committing, and keep work-specific
`autoMode.environment` data out of this public repo.

# docs

Notes live in `docs/`. `docs/ideas/` holds parked, unimplemented ideas — not to be acted on.

# cool stuff

## timer
```sh
# run to start a timer that shows up on waybar!
timer 5m
timer 30s
```

# known issues
## elephant-windows
Because Omarchy repo has its own version of the elephant package. Upgrading system packages **might** pull a newer version of elephant plugins from AUR. This version mismatch **might** break if the Go used to compile the plugin is different from the one used to compile the main package. The solution is to manually build the plugin with the system's Go.
