# dotfiles for a very nice (m)arch

> thanks Omarchy for all the quality of life improvements

```sh
# installs the omarchy base (inits the submodule first)
./install.sh -o

# installs customizations
./install.sh -pswk

# reports drift between this repo and the machine
./install/doctor.sh
```

# layout

| Path | Holds |
|---|---|
| `install.sh`, `install/` | the bootstrap command and its sub-steps |
| `config/` | dotfiles symlinked into `$HOME`; `config/_home/*` keeps its subpath, the rest lands in `~/.config` |
| `claude/` | Claude Code skills marketplace — see below |
| `scripts/` | executables linked into `/usr/local/lib/march` and `~/.local/bin` |
| `systemd/` | backup service and timer units — see [systemd/README.md](systemd/README.md) |
| `branding/`, `wallpapers/`, `sounds/`, `webapps/` | assets the installers copy or link |
| `fixes/` | idempotent post-install fixes — see [fixes/README.md](fixes/README.md) |
| `pkg.list` | packages installed by `./install.sh -p` |
| `omarchy` | omarchy fork submodule, booted by `./install.sh -o` |

VS Code settings and keybindings live in the private dotfiles repo, not here.
`install/vscode_extensions.sh` still installs the extensions.

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
# run to start a timer that sends a notification and plays an alarm
timer 5m
timer 30s
```

The bar countdown died with waybar (Omarchy 4 replaced it with the
Quickshell bar). To bring it back, write an omarchy shell plugin
that reads `/tmp/waybar_timer.json`.
