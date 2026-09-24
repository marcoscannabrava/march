# dotfiles for a very nice (m)arch

> thanks Omarchy for all the quality of life improvements

```sh
# installs the omarchy base (inits the submodule first)
./install.sh -o

# installs customizations
./install.sh -pswka

# reports drift between this repo and the machine
./install/doctor.sh
```

# layout

| Path | Holds |
|---|---|
| `install.sh`, `install/` | the bootstrap command and its sub-steps |
| `config/` | dotfiles symlinked into `$HOME`; `config/_home/*` keeps its subpath, the rest lands in `~/.config` |
| `agents/` | vendored agent plugins (pstack) wired into claude, codex, and pi — see below |
| `scripts/` | executables linked into `/usr/local/lib/march` and `~/.local/bin` |
| `systemd/` | backup service and timer units — see [systemd/README.md](systemd/README.md) |
| `branding/`, `wallpapers/`, `sounds/`, `webapps/` | assets the installers copy or link |
| `fixes/` | idempotent post-install fixes — see [fixes/README.md](fixes/README.md) |
| `pkg.list` | packages installed by `./install.sh -p` |
| `omarchy` | omarchy fork submodule, booted by `./install.sh -o` |

VS Code settings and keybindings live in the private dotfiles repo, not here.
`install/vscode_extensions.sh` still installs the extensions.

## agent plugins (pstack)

`agents/pstack-claude/` vendors [pstack](https://github.com/michael-denyer/pstack-claude) (~30
workflow skills: `why`, `how`, `interrogate`, `arena`, …) as the single source of truth, and
`./install.sh -a` wires it natively into all three agents:

- **Claude**: local marketplace (`claude plugin marketplace add`), declared in
  `config/_home/.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`).
- **Codex**: native plugin system (`codex plugin marketplace add` + `codex plugin add`), declared
  in `config/_home/.codex/config.toml`. The marketplace runs in place from the repo; the plugin
  itself is cached under `~/.codex/plugins/cache/`.
- **Pi**: one symlink into `~/.pi/agent/skills/pstack` — live immediately, invoke as `/skill:why`.

The vendored tree is pristine — never patch it. To update pstack, follow
[agents/pstack-claude/UPSTREAM.md](agents/pstack-claude/UPSTREAM.md), then refresh the derived
caches: `claude plugin update pstack@pstack-claude`, and for Codex
`codex plugin remove pstack && codex plugin add pstack@pstack-claude`. Pi needs nothing.
Moving this checkout requires `./install.sh -a` again (absolute paths are baked into the
declarations).

Note: Claude rewrites `installed_plugins.json` / `known_marketplaces.json` atomically on plugin
operations, which replaces the symlinks with regular files. `install/doctor.sh` reports this as
drift — re-run `./install.sh -s` to restore the links, then commit the synced content.

## omarchy toggles

`config/_home/.local/state/omarchy/toggles/screensaver-off` is an empty flag file. Omarchy only
looks for the file, so the symlink keeps the screensaver off. `omarchy toggle screensaver` deletes
the link to turn the screensaver back on — run `./install.sh -s` to put it back.

# docs

Notes live in `docs/`. `docs/ideas/` holds parked, unimplemented ideas — not to be acted on.

# cool stuff

## timer

```sh
timer 5m              # notification and alarm after 5 minutes
timer 30s
timer 10              # a bare number means minutes
timer 25m "stand up"  # custom notification message
timer stop
```

The top bar counts down just left of the clock. `timer` writes an end
timestamp to `~/.local/state/march/timer.json` and calls the bar widget over
shell IPC. The widget does the ticking, so it shows the correct time even if
the shell reloads mid-timer. It takes no space when no timer runs.

The widget is an omarchy shell plugin in
[config/omarchy/plugins/marcos.countdown](config/omarchy/plugins/marcos.countdown).
`bar.layout.center` in `config/omarchy/shell.json` places it. Omarchy caches
plugin QML per file path, so run `omarchy-restart-shell` after you edit the
plugin.
