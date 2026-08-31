# march

Personal dotfiles for Arch + Hyprland on top of an [Omarchy](https://omarchy.org) fork.
Bash scripts, config files, and Claude Code skills. No build, no test suite, no package manager.

Read `README.md` first for the layout table and the user-facing commands. This file holds what
the README does not: how to work in the repo without breaking the machine it configures.

## This repo is the live machine

`./install.sh -s` symlinks `config/`, `scripts/`, `sounds/`, and the Claude skills into `$HOME`
and `/usr/local/lib/march`. The links point back here, so **editing a versioned file changes the
running system at once**. There is no deploy step.

- Edit an already-linked file → the change is live. Reload the affected program (below).
- Add a new file under `config/` or `scripts/` → run `./install.sh -s` to link it.
- Rename or delete a file → the old symlink dangles. `install/doctor.sh` will not catch it;
  remove the stale target by hand.

Path mapping in the `-s` loop: `config/_home/X` → `~/X`, everything else `config/X` → `~/.config/X`.

`scripts/backup`, `scripts/backup_gdrive`, and `scripts/restore` are **copied**, not linked, by
`install/backup_systemd.sh`. Editing them does nothing until that installer runs again.

## Verify with doctor, not tests

```sh
./install/doctor.sh     # reports drift between repo and machine
bash -n <script>        # syntax check before running anything
```

`doctor.sh` is the closest thing to a test suite. Run it after any change to `install.sh`,
`install/`, or the layout of `config/` and `scripts/`. It must stay in sync with the link rules
in `install.sh` — change one, change the other.

For behavior, run the real thing: `timer 5s`, `/usr/local/lib/march/backup --dry-run`,
`omarchy-shell -q <plugin> reload`.

## Reload after editing

| Edited | Reload |
|---|---|
| `config/hypr/*.lua` | `hyprctl reload` |
| `config/omarchy/plugins/**/*.qml`, `shell.json` | `omarchy-restart-shell` — QML is cached per path |
| `config/zsh/*`, `config/_home/.zshrc` | new shell, or `source ~/.zshrc` |
| `install/keymap.keyd.conf` | `./install.sh -k` |

## Conventions

- **Idempotent.** Every installer converges: re-running changes nothing. `ensure_link` in
  `install.sh` and `config_pacman` in `utils.sh` are the pattern to copy — check the desired
  state, skip with `log_yellow`, act and report with `log_green`.
- **Location-independent.** Scripts resolve their own dir: `REPO_DIR="$(dirname "$(readlink -f "$0")")"`. Never assume the checkout is at `~/code/march`.
- **Logging.** Source `utils.sh` and use `log_purple` (section), `log_green` (done),
  `log_yellow` (skipped), `log_red` (failed). No bare `echo` for status.
- **Strict mode where a failure matters.** `scripts/backup`, `backup_gdrive`, `restore`, and
  `install/backup_systemd.sh` use `set -Eeuo pipefail`. `install.sh` does not, so a failed step
  does not abort the run — check `$?` or guard explicitly when you add one.
- **`pkg.list`** is `package | one-line description`, grouped under `# ---- // Section` headers.
  The installer cuts on `|`, so the description is free text.
- **Never `sudo` without need.** Only `/usr/local/lib/march`, `/etc/systemd/system`, and
  `/etc/pacman.conf` writes take it.

## Do not touch

- `notes/*` — parked notes. Do not read them, do not
  act on them.
- `omarchy/` — submodule, currently uninitialized. Only `./install.sh -o` populates it. Do not
  `git submodule update` as a side effect of other work.
- `config/_home/.claude/.credentials.json` — gitignored OAuth token. Never read, print, or commit it.

## Claude Code config lives here too

`~/.claude/CLAUDE.md`, `settings.json`, and `pstack-models.md` are symlinks into
`config/_home/.claude/`. Editing them rewrites your own instructions mid-session.

Claude Code writes back to `settings.json` (auto-mode environment notes) and
`plugins/installed_plugins.json` (plugin updates). Those writes land in the working tree as
uncommitted changes. Before committing, check the diff and strip any work-specific
`autoMode.environment` data — this repo is public.

Skills under `claude/plugins/ship/skills/` are also symlinked into `~/.claude/skills/`. A new
skill needs `./install.sh -s` plus a Claude Code restart. See `claude/README.md`.

## Commits

Short lowercase subjects, conventional prefix when it fits: `feat:`, `fix:`, `style:`.
Plain descriptions are fine too. Do not commit unless asked.
