# PLAN: march AUR Package — Remove Omarchy Dependency

## Overview

Transform `march` from a dotfiles repo with an omarchy git submodule into a **standalone AUR package** (`march`) that ships its own scripts, configs, and a `PKGBUILD`. The omarchy submodule is removed entirely. All essential desktop environment functionality is reimplemented or inlined.

---

## Architecture

```
march/
├── PKGBUILD                    # AUR package build file
├── march.install               # pacman install hooks (post_install, post_upgrade)
├── bin/                        # Scripts installed to /usr/bin/march-*
│   ├── march                   # Main CLI entry point (march install, march update, etc.)
│   ├── march-menu              # SUPER+ALT+SPACE menu (reimplemented from omarchy-menu)
│   ├── march-launch-webapp     # Web app launcher
│   ├── march-launch-browser    # Browser launcher
│   ├── march-launch-or-focus   # Focus existing window or launch app
│   ├── march-launch-or-focus-webapp
│   ├── march-launch-walker     # Walker launcher (with elephant)
│   ├── march-launch-wifi       # WiFi TUI launcher
│   ├── march-launch-editor     # Editor launcher
│   ├── march-launch-tui        # TUI app launcher (btop, lazydocker)
│   ├── march-launch-floating-terminal  # Floating terminal for presentation
│   ├── march-cmd-terminal-cwd  # Get CWD from active terminal
│   ├── march-cmd-screenshot    # Screenshot tool (slurp+grim+satty)
│   ├── march-cmd-screenrecord  # Screen recording (gpu-screen-recorder)
│   ├── march-battery-monitor   # Low battery notification daemon
│   ├── march-battery-remaining # Get battery percentage
│   ├── march-lock-screen       # Lock screen (hyprlock)
│   ├── march-snapshot          # Btrfs snapshot management (snapper)
│   ├── march-refresh-limine    # Limine bootloader config refresh
│   ├── march-toggle-waybar     # Toggle waybar visibility
│   ├── march-toggle-idle       # Toggle idle/lock behavior
│   ├── march-toggle-nightlight # Toggle hyprsunset
│   ├── march-restart-waybar    # Restart waybar
│   └── march-tz-select         # Timezone selector
├── config/                     # Dotfiles → symlinked to ~/.config/
│   ├── hypr/
│   │   ├── hyprland.conf       # Main hyprland config (self-contained, no omarchy sources)
│   │   ├── autostart.conf      # Autostart apps
│   │   ├── bindings/
│   │   │   ├── media.conf      # Media keys (volume, brightness, playerctl)
│   │   │   ├── clipboard.conf  # Copy/paste/clipboard manager
│   │   │   ├── tiling.conf     # Tiling, workspaces, window management
│   │   │   └── utilities.conf  # Menus, captures, notifications, toggles
│   │   ├── apps.conf           # App-specific window rules
│   │   ├── envs.conf           # Environment variables (Wayland, cursor, XDG)
│   │   ├── input.conf          # Input configuration
│   │   ├── looknfeel.conf      # Theme, animations, decorations (Tokyo Night hardcoded)
│   │   ├── windows.conf        # Global window rules
│   │   ├── monitors.conf       # Monitor/workspace layout
│   │   ├── workspaces.conf     # Workspace assignments
│   │   └── hypridle.conf       # Idle timeouts
│   ├── waybar/
│   │   ├── config.jsonc        # Waybar modules (no omarchy refs)
│   │   └── style.css           # Tokyo Night waybar theme (inlined, no @import)
│   ├── mako/
│   │   └── config              # Notification daemon (Tokyo Night colors inlined)
│   ├── alacritty/
│   │   └── alacritty.toml      # Terminal config (Tokyo Night colors inlined)
│   ├── walker/
│   │   ├── config.toml         # Walker launcher config
│   │   └── themes/march/       # Walker theme (Tokyo Night, self-contained)
│   │       ├── style.css
│   │       └── layout.xml
│   ├── elephant/               # Elephant search index configs
│   ├── btop/
│   │   └── btop.conf           # System monitor (Tokyo Night theme inlined)
│   ├── swayosd/                # OSD styling (Tokyo Night)
│   ├── uwsm/
│   │   ├── env                 # UWSM environment (PATH includes march bin)
│   │   └── default             # Default terminal & editor
│   ├── zsh/
│   │   ├── .zshrc
│   │   └── .aliases
│   ├── Code/User/              # VSCode settings
│   ├── _home/
│   │   └── .gitconfig          # Git config
│   └── waybar/indicators/
│       └── screen-recording.sh # Screen recording waybar indicator
├── themes/                     # Tokyo Night theme files (static, no switching)
│   └── tokyo-night/
│       ├── hyprland.conf
│       ├── waybar.css
│       ├── alacritty.toml
│       ├── mako.ini
│       ├── btop.theme
│       ├── swayosd.css
│       └── walker.css
├── systemd/                    # Systemd units
│   ├── march-battery-monitor.service
│   ├── march-battery-monitor.timer
│   ├── backup.service
│   ├── backup.timer
│   ├── backup-gdrive.service
│   └── backup-gdrive.timer
├── install/                    # Install helper scripts
│   ├── limine-snapper.sh       # Limine bootloader + Snapper setup
│   ├── keymap.sh
│   ├── wallpapers.sh
│   ├── splashscreen.sh
│   ├── branding.sh
│   ├── zsh.sh
│   ├── vscode_extensions.sh
│   ├── webapps.sh
│   └── backup_systemd.sh
├── wallpapers/
├── sounds/
├── webapps/
├── scripts/                    # Utility scripts (backup, timer)
└── git/
```

---

## Step-by-step Plan

### Phase 1: Create PKGBUILD and Package Structure

#### 1.1 Create `PKGBUILD`

Create a standard AUR PKGBUILD that:
- **pkgname**: `march`
- **pkgver**: `1.0.0`
- **source**: git repo (`git+https://github.com/marcoscannabrava/march.git`)
- **depends**: Core desktop environment packages (see package list below)
- **optdepends**: Personal/optional packages (slack, dbeaver, google-chrome, etc.)
- **install**: `march.install` (post-install hooks)
- **package()**: Installs `bin/*` scripts to `/usr/bin/`, installs systemd units to appropriate locations, installs theme files to `/usr/share/march/`

#### 1.2 Define Package Dependencies

**`depends` array** — packages required for the basic desktop environment:
```
# Core WM & Wayland
hyprland hyprland-guiutils hypridle hyprlock hyprsunset hyprpicker
uwsm sddm plymouth xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
xdg-terminal-exec

# Bar, Launcher, Notifications
waybar walker elephant-windows mako swayosd swaybg

# Terminal & Shell
alacritty zsh

# Core CLI Tools
git git-lfs github-cli jq gum fzf ripgrep bat eza zoxide fd
less unzip wget whois tldr plocate expac inxi starship

# Screenshot & Recording
grim slurp satty wayfreeze gpu-screen-recorder wl-clipboard

# System & Hardware
power-profiles-daemon brightnessctl ufw playerctl pamixer wireplumber
pipewire pipewire-alsa pipewire-jack pipewire-pulse

# File Management
nautilus gvfs-mtp gvfs-nfs gvfs-smb sushi ffmpegthumbnailer

# Boot & Snapshots
limine limine-mkinitcpio-hook limine-snapper-sync snapper btrfs-progs

# Fonts & Theming
ttf-jetbrains-mono-nerd ttf-cascadia-mono-nerd noto-fonts noto-fonts-cjk
noto-fonts-emoji noto-fonts-extra fontconfig woff2-font-awesome
gnome-themes-extra yaru-icon-theme kvantum-qt5

# Wayland Support
qt5-wayland qt6-wayland egl-wayland
webp-pixbuf-loader

# Development Base
base base-devel git

# Input & Localization
fcitx5 fcitx5-gtk fcitx5-qt

# System Utilities
btop imagemagick localsend impala wiremix imv blueberry
gnome-keyring libsecret gnome-calculator gnome-disk-utility
nwg-displays keychain

# Misc
avahi nss-mdns inetutils cups cups-browsed cups-filters cups-pdf
polkit-gnome system-config-printer

# Package Management
yay
```

**Removed from omarchy-base.packages** (not needed for basic DE):
- `lazygit` — removed per requirements
- `typora` — removed per requirements
- `obsidian` — removed per requirements
- `omarchy-chromium` — replaced with plain chromium or google-chrome as optdepend
- `omarchy-nvim` — nvim as optdepend
- `omarchy-walker` — use walker directly
- `ghostty`, `kitty` — removed, alacritty only
- `chromium` — optdepend only
- `1password-beta`, `1password-cli` — optdepend
- `aether` — omarchy-specific
- `asdcontrol` — omarchy-specific
- `cargo`, `clang`, `llvm`, `luarocks`, `tree-sitter-cli` — dev tools as optdepend
- `docker`, `docker-buildx`, `docker-compose` — dev tools as optdepend
- `lazydocker` — removed per requirements
- `evince`, `kdenlive`, `libreoffice`, `obs-studio`, `pinta`, `spotify`, `xournalpp` — apps as optdepend
- `mise`, `python-poetry-core` — dev tools as optdepend
- `signal-desktop` — app as optdepend
- `python-terminaltexteffects` — omarchy visual fluff

**optdepends array** (not installed by default):
```
google-chrome, docker, docker-buildx, docker-compose, 1password-beta,
1password-cli, nvim, spotify, signal-desktop, dbeaver, slack-desktop,
qbittorrent-nox, rclone-git, nwg-displays, gnome-clocks, mise,
libreoffice, obs-studio, evince, kdenlive
```

#### 1.3 Create `march.install` (pacman hooks)

```bash
post_install() {
    echo ":: Run 'march install' to symlink dotfiles and configure your system."
    echo ":: Run 'march install --limine' to set up the Limine bootloader."
}
```

---

### Phase 2: Create `bin/march` CLI Entry Point

The `march` command replaces `install.sh` as the main entry point:

```
march install           # Symlink all dotfiles to ~/.config, set up shell, etc.
march install --limine  # Configure Limine bootloader + Snapper snapshots
march install --keymap  # Configure keyd keymap
march install --wallpapers  # Install wallpapers & splashscreen
march install --vscode  # Install VSCode extensions
march install --webapps # Install web app .desktop files
march install --backup  # Set up systemd backup timers
march install --all     # Run all of the above
march snapshot [create|restore]  # Manage Btrfs snapshots
march update            # System update with snapshot safety
```

Implementation:
- Move logic from current `install.sh` into `bin/march`
- The `install` subcommand symlinks `config/*` → `~/.config/*` (same logic as current `-s` flag)
- Also symlinks `scripts/*` → `/usr/local/lib/march/` and `sounds/*` → `~/.local/share/sounds/`
- Remove the `-o` (omarchy) flag entirely
- Remove interactive prompts; use explicit flags instead

---

### Phase 3: Reimplement Omarchy Scripts as `march-*` Commands

Port essential omarchy scripts. Most are small (5–30 lines) and straightforward.

#### 3.1 Launcher Scripts (copy with s/omarchy/march/g + minor edits)

| New script | Source | Lines | Changes needed |
|---|---|---|---|
| `march-launch-webapp` | `omarchy-launch-webapp` | 11 | Rename only |
| `march-launch-browser` | `omarchy-launch-browser` | 12 | Rename only |
| `march-launch-or-focus` | `omarchy-launch-or-focus` | 16 | Rename only |
| `march-launch-or-focus-webapp` | `omarchy-launch-or-focus-webapp` | 12 | Call march-launch-or-focus |
| `march-launch-walker` | `omarchy-launch-walker` | 13 | Rename only |
| `march-launch-wifi` | `omarchy-launch-wifi` | 3 | Rename only |
| `march-launch-editor` | `omarchy-launch-editor` | 12 | Remove `omarchy-cmd-present`, use `command -v` |
| `march-launch-tui` | `omarchy-launch-tui` | ~10 | Rename only |
| `march-launch-floating-terminal` | `omarchy-launch-floating-terminal-with-presentation` | 4 | Remove omarchy-show-logo/done references |
| `march-cmd-terminal-cwd` | `omarchy-cmd-terminal-cwd` | 17 | Rename only |

#### 3.2 Screenshot & Screen Recording (copy with minor edits)

| New script | Source | Lines | Changes needed |
|---|---|---|---|
| `march-cmd-screenshot` | `omarchy-cmd-screenshot` | 83 | Rename, remove theme refs if any |
| `march-cmd-screenrecord` | `omarchy-cmd-screenrecord` | 142 | Rename, update waybar signal refs |

#### 3.3 Battery & Power Scripts

| New script | Source | Lines | Changes needed |
|---|---|---|---|
| `march-battery-monitor` | `omarchy-battery-monitor` | 23 | Call march-battery-remaining |
| `march-battery-remaining` | `omarchy-battery-remaining` | 8 | Rename only |

#### 3.4 Boot & Snapshot Scripts

| New script | Source | Lines | Changes needed |
|---|---|---|---|
| `march-snapshot` | `omarchy-snapshot` | 34 | Replace `omarchy-version` with `march --version` |
| `march-refresh-limine` | `omarchy-refresh-limine` | ~30 | Rebrand "Omarchy" → "mArch" in bootloader text |

#### 3.5 System Toggle Scripts

| New script | Source | Lines | Changes needed |
|---|---|---|---|
| `march-lock-screen` | `omarchy-lock-screen` | 12 | Rename only |
| `march-toggle-waybar` | `omarchy-toggle-waybar` | ~5 | Rename only |
| `march-toggle-idle` | `omarchy-toggle-idle` | ~5 | Rename only |
| `march-toggle-nightlight` | `omarchy-toggle-nightlight` | ~5 | Rename only |
| `march-restart-waybar` | `omarchy-restart-waybar` | ~3 | Rename only |
| `march-tz-select` | `omarchy-tz-select` | 6 | Call march-restart-waybar |

#### 3.6 The Menu — `march-menu` (SUPER+ALT+SPACE)

This is the most complex script (~486 lines). **Simplify significantly:**

- **Keep**: System menu (lock, suspend, reboot, shutdown), Power profiles, Screenshot/screenrecord triggers, WiFi/Bluetooth launchers
- **Remove**: Theme switching (Style submenu), Font switching, Install/Remove submenus (use pacman directly), Learn submenu, Update submenu (use `march update` CLI), About
- **Result**: ~150-200 lines, focused on daily-use quick actions

#### 3.7 Scripts NOT needed (handled by other tools or removed)

- All `omarchy-theme-*` scripts (no theme switching)
- All `omarchy-font-*` scripts (no font switching)
- All `omarchy-refresh-*` scripts except `march-refresh-limine` (no dynamic config refresh)
- All `omarchy-update-*` scripts (replaced by simple `march update`)
- All `omarchy-install-*` scripts (use pacman/yay directly)
- All `omarchy-pkg-*` scripts (use pacman/yay directly)
- All `omarchy-tui-*` scripts (use pacman/yay directly)
- All `omarchy-webapp-*` scripts except `march-launch-webapp`
- `omarchy-debug`, `omarchy-hook`, `omarchy-migrate`, `omarchy-state`
- `omarchy-cmd-first-run`, `omarchy-cmd-share`, `omarchy-cmd-audio-switch`
- `omarchy-show-logo`, `omarchy-show-done`
- `omarchy-windows-vm`, `omarchy-setup-*`
- `omarchy-menu-keybindings` (nice to have, could add later)

---

### Phase 4: Inline Tokyo Night Theme Into All Configs

The key insight: instead of `@import "../omarchy/current/theme/..."`, we hardcode the Tokyo Night colors directly into each config file.

#### 4.1 Tokyo Night Color Palette (reference)

```
Background:     #1a1b26
Foreground:     #a9b1d6 / #c0caf5 / #cdd6f4
Border/Accent:  #33ccff
Black:          #32344a / #444b6a (bright)
Red:            #f7768e / #ff7a93
Green:          #9ece6a / #b9f27c
Yellow:         #e0af68 / #ff9e64
Blue:           #7aa2f7 / #7da6ff
Magenta:        #ad8ee6 / #bb9af7
Cyan:           #449dab / #0db9d7
White:          #787c99 / #acb0d0
Selection BG:   #7aa2f7
Surface:        #414868
Muted:          #565f89
```

#### 4.2 Files to Modify

1. **`config/waybar/style.css`**: Replace `@import "../omarchy/current/theme/waybar.css"` with:
   ```css
   @define-color foreground #cdd6f4;
   @define-color background #1a1b26;
   ```

2. **`config/mako/config`**: Replace `include=~/.config/omarchy/current/theme/mako.ini` with inlined mako core config + Tokyo Night colors:
   ```ini
   # Core settings (from omarchy default/mako/core.ini)
   anchor=top-right
   default-timeout=5000
   width=420
   outer-margin=20
   padding=10,15
   border-size=2
   max-icon-size=32
   font=sans-serif 14px

   # Tokyo Night colors
   text-color=#c0caf5
   border-color=#33ccff
   background-color=#1a1b26

   [app-name=Spotify]
   invisible=1

   [mode=do-not-disturb]
   invisible=true

   [mode=do-not-disturb app-name=notify-send]
   invisible=false

   [urgency=critical]
   default-timeout=0

   # march-specific
   [app-name=Clocks]
   on-notify=exec mpv --volume-gain=30 ~/.local/share/sounds/default-alarm.mp3
   ```

3. **`config/alacritty/alacritty.toml`**: Replace `general.import = [ "~/.config/omarchy/current/theme/alacritty.toml" ]` with inlined Tokyo Night colors from `themes/tokyo-night/alacritty.toml`

4. **`config/walker/themes/march/style.css`**: Replace `@import` of omarchy theme with inlined Tokyo Night walker.css color variables

5. **`config/btop/btop.conf`**: Set `color_theme` to the Tokyo Night theme file path (ship `themes/tokyo-night/btop.theme` to `/usr/share/march/themes/btop.theme`)

6. **`config/swayosd/style.css`**: Inline Tokyo Night colors

7. **`config/hypr/looknfeel.conf`**: Already has Tokyo Night-compatible border colors. Remove any `source` of omarchy theme conf.

---

### Phase 5: Rewrite Hyprland Config (Self-Contained)

The current `config/hypr/hyprland.conf` in omarchy sources 10+ files from `~/.local/share/omarchy/`. Replace with a **self-contained config** that sources only from `~/.config/hypr/`.

#### 5.1 New `config/hypr/hyprland.conf`

```conf
# mArch Hyprland Configuration
# All configs are self-contained — no external omarchy dependencies

source = ~/.config/hypr/envs.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/looknfeel.conf
source = ~/.config/hypr/autostart.conf
source = ~/.config/hypr/windows.conf
source = ~/.config/hypr/apps.conf
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/workspaces.conf

# Bindings (split for clarity)
source = ~/.config/hypr/bindings/media.conf
source = ~/.config/hypr/bindings/clipboard.conf
source = ~/.config/hypr/bindings/tiling.conf
source = ~/.config/hypr/bindings/utilities.conf
source = ~/.config/hypr/bindings.conf  # User custom overrides (current file)
```

#### 5.2 Merge omarchy defaults + march overrides

For each config section, merge the omarchy default content with the march customizations:

- **`envs.conf`**: Copy from omarchy `default/hypr/envs.conf`, keep Wayland env vars. Remove `OMARCHY_PATH`. Add `MARCH_PATH=/usr/share/march`.
- **`autostart.conf`**: Copy omarchy defaults (hypridle, mako, waybar, swaybg, swayosd, polkit, elephant, walker). Remove `omarchy-cmd-first-run`. Add march-specific autostart. Point `swaybg` to a static wallpaper path.
- **`input.conf`**: Merge omarchy default + march override (accel_profile, numlock, touchpad).
- **`looknfeel.conf`**: Merge omarchy defaults (animations, dwindle, etc.) + march overrides (rounding, gaps, border colors). Hardcode Tokyo Night border colors.
- **`windows.conf`**: Copy omarchy default window rules. Inline the app-specific rules from `apps.conf` (keeping only relevant ones: browser, terminals, walker, system).
- **`bindings/media.conf`**: Copy from omarchy as-is.
- **`bindings/clipboard.conf`**: Copy from omarchy, change `omarchy-launch-walker` → `march-launch-walker`.
- **`bindings/tiling.conf`**: Copy from omarchy `tiling-v2.conf`. Remove `omarchy-hyprland-*` refs, inline their simple logic.
- **`bindings/utilities.conf`**: Rewrite to use `march-*` commands. Remove theme/font/style bindings. Keep: screenshot, screenrecord, notifications, menus, lock, toggles.
- **`bindings.conf`**: Keep current march custom bindings, but replace all `omarchy-*` → `march-*`.

#### 5.3 Specific Binding Replacements in `bindings.conf`

| Old | New |
|---|---|
| `omarchy-launch-browser` | `march-launch-browser` |
| `omarchy-cmd-terminal-cwd` | `march-cmd-terminal-cwd` |
| `omarchy-launch-or-focus spotify` | `march-launch-or-focus spotify` |
| `omarchy-launch-editor` | `march-launch-editor` |
| `omarchy-launch-tui btop` | `$terminal -e btop` (simpler) |
| `omarchy-launch-tui lazydocker` | `$terminal -e lazydocker` (if installed) |
| `omarchy-launch-webapp "URL"` | `march-launch-webapp "URL"` |
| `omarchy-menu` | `march-menu` |
| `omarchy-launch-terminal` | `uwsm-app -- $TERMINAL` |
| `omarchy-launch-wifi` | `march-launch-wifi` |
| `omarchy-launch-bluetooth` | `blueberry` (direct) |
| `omarchy-cmd-screenrecord` | `march-cmd-screenrecord` |
| `omarchy-cmd-screenshot` | `march-cmd-screenshot` |
| `omarchy-lock-screen` | `march-lock-screen` |
| `omarchy-launch-walker` | `march-launch-walker` |
| `omarchy-menu system` | `march-menu system` |
| `omarchy-toggle-waybar` | `march-toggle-waybar` |
| `omarchy-toggle-idle` | `march-toggle-idle` |
| `omarchy-toggle-nightlight` | `march-toggle-nightlight` |
| `omarchy-battery-remaining` | `march-battery-remaining` |

---

### Phase 6: Update Waybar Config

#### 6.1 `config/waybar/config.jsonc`

Replace all omarchy references:

| Old | New |
|---|---|
| `"on-click": "omarchy-menu"` | `"on-click": "march-menu"` |
| `"on-click-right": "omarchy-launch-terminal"` | `"on-click-right": "uwsm-app -- $TERMINAL"` |
| `"exec": "omarchy-update-available"` | Remove `custom/update` module entirely (or replace with simple pacman check) |
| `"on-click": "omarchy-launch-floating-terminal-with-presentation omarchy-update"` | Remove or replace with `march update` |
| `"on-click-right": "omarchy-launch-floating-terminal-with-presentation omarchy-tz-select"` | `"on-click-right": "march-tz-select"` (run in floating terminal) |
| `"on-click": "omarchy-launch-wifi"` | `"on-click": "march-launch-wifi"` |
| `"on-click": "omarchy-launch-bluetooth"` | `"on-click": "blueberry"` |
| `"on-click": "omarchy-cmd-screenrecord"` | `"on-click": "march-cmd-screenrecord"` |
| `"exec": "$OMARCHY_PATH/default/waybar/indicators/screen-recording.sh"` | `"exec": "/usr/share/march/indicators/screen-recording.sh"` |
| `"on-click": "omarchy-menu power"` | `"on-click": "march-menu power"` |
| `"tooltip-format": "Omarchy Menu..."` | `"tooltip-format": "mArch Menu\n\nSuper + Alt + Space"` |

#### 6.2 `config/waybar/style.css`

Replace the theme import with inlined Tokyo Night colors (see Phase 4.2).

---

### Phase 7: Update Remaining Config Files

#### 7.1 `config/hypr/hypridle.conf`

Replace `omarchy-lock-screen` → `march-lock-screen`.

#### 7.2 `config/mako/config`

Inline the full mako config (core.ini + Tokyo Night + march customizations). Remove all `omarchy-*` references from notification actions. Remove the "Setup Wi-Fi", "Update System", "Learn Keybindings" action handlers (omarchy-specific first-run features).

#### 7.3 `config/uwsm/env`

Replace:
```bash
export OMARCHY_PATH=$HOME/.local/share/omarchy
export PATH=$OMARCHY_PATH/bin:$PATH
```
With:
```bash
export PATH=/usr/bin:$PATH  # march-* scripts installed system-wide via PKGBUILD
```
Remove `omarchy-cmd-present` reference; use `command -v mise` instead.

#### 7.4 `config/walker/config.toml`

Change theme from `"omarchy-default"` to `"march"`.
Change `additional_theme_location` to `"/usr/share/march/walker/themes/"` or `"~/.config/walker/themes/"`.

#### 7.5 `config/zsh/.aliases` and `config/zsh/.zshrc`

No omarchy references — these are already clean. No changes needed.

---

### Phase 8: Set Up Limine Bootloader & Snapper Install Script

#### 8.1 `install/limine-snapper.sh`

Port from omarchy's `install/login/limine-snapper.sh` (143 lines):
- Rebrand all "Omarchy" text → "mArch"
- Keep Tokyo Night bootloader theme (term colors, background)
- Keep UKI creation logic
- Keep Snapper configuration for root/home subvolumes
- Keep limine-snapper-sync setup
- This script is called via `march install --limine`

---

### Phase 9: Set Up Systemd Units

#### 9.1 Battery Monitor

Port from omarchy:
- `march-battery-monitor.service` — runs `march-battery-monitor`
- `march-battery-monitor.timer` — triggers every 30 seconds
- Enabled during `march install` if battery is detected

#### 9.2 Existing Backup Timers

Keep the existing `backup.service`, `backup.timer`, `backup-gdrive.service`, `backup-gdrive.timer` as-is (they don't reference omarchy).

---

### Phase 10: Remove Omarchy Submodule

#### 10.1 Git Operations

```bash
git submodule deinit -f omarchy
git rm -f omarchy
rm -rf .git/modules/omarchy
rm .gitmodules  # or edit to remove the [submodule "omarchy"] section
```

#### 10.2 Remove `install.sh` `-o` flag

The new `bin/march` CLI replaces `install.sh`. We can either:
- **Option A**: Keep `install.sh` as a legacy wrapper that calls `march install`
- **Option B**: Delete `install.sh` entirely and rely on `march` CLI (preferred)

---

### Phase 11: Install Walker Theme Files

The walker theme currently lives at `~/.local/share/omarchy/default/walker/themes/omarchy-default/`. Replace with:

- Ship `config/walker/themes/march/style.css` and `layout.xml` as part of the march package
- The PKGBUILD installs these to `/usr/share/march/walker/themes/march/`
- OR symlink them to `~/.config/walker/themes/march/` during `march install`
- Update `config/walker/config.toml` to reference `theme = "march"`

Inline Tokyo Night walker CSS variables into the theme's `style.css`:
```css
@define-color base #1a1b26;
@define-color text #a9b1d6;
@define-color border #33ccff;
@define-color selected-text #c0caf5;
@define-color background #1a1b26;
```

---

### Phase 12: Ship the `omarchy.ttf` Icon Font

The waybar config uses `<span font='omarchy'>\ue900</span>` for the menu icon. Options:
- **Option A**: Keep the font and ship it with march package (install to `/usr/share/fonts/march/`)
- **Option B**: Replace with a standard Nerd Font icon (e.g., Arch Linux logo `\uf303` or a simple icon)

Recommend **Option B** — replace `<span font='omarchy'>\ue900</span>` with a Nerd Font icon like `""` (Arch logo) to avoid shipping a custom font.

---

### Phase 13: Screen Recording Indicator

Move `default/waybar/indicators/screen-recording.sh` to the march package:
- Install to `/usr/share/march/indicators/screen-recording.sh`
- Update waybar config to reference the new path
- Script content is 7 lines, no omarchy dependencies

---

## Summary of All omarchy-* References to Replace

Every file that references `omarchy` must be updated. Here's the complete mapping:

| File | What to do |
|---|---|
| `.gitmodules` | Delete file (or remove submodule entry) |
| `omarchy/` | Remove entire submodule |
| `install.sh` | Replace with `bin/march` CLI |
| `config/hypr/bindings.conf` | Replace all `omarchy-*` → `march-*` |
| `config/hypr/hypridle.conf` | `omarchy-lock-screen` → `march-lock-screen` |
| `config/waybar/config.jsonc` | Replace all `omarchy-*` → `march-*`, remove `$OMARCHY_PATH` |
| `config/waybar/style.css` | Inline Tokyo Night colors, remove omarchy import |
| `config/mako/config` | Inline full config, remove omarchy include |
| `config/alacritty/alacritty.toml` | Inline Tokyo Night colors, remove omarchy import |
| `config/uwsm/env` | Remove `OMARCHY_PATH`, update PATH |
| `config/walker/config.toml` | Change theme name and path |
| `webapps/Google AI Studio.desktop` | Replace `omarchy-launch-webapp` → `march-launch-webapp` |

---

## Execution Order

1. **Phase 1**: Create PKGBUILD + package structure
2. **Phase 3**: Port all `bin/march-*` scripts from omarchy (needed before config changes)
3. **Phase 4**: Inline Tokyo Night theme into all config files
4. **Phase 5**: Rewrite Hyprland config to be self-contained
5. **Phase 6**: Update Waybar config
6. **Phase 7**: Update remaining configs (mako, uwsm, walker, hypridle)
7. **Phase 8**: Port Limine/Snapper install script
8. **Phase 9**: Port systemd units (battery monitor)
9. **Phase 11–13**: Walker theme, font, screen recording indicator
10. **Phase 2**: Create `bin/march` CLI entry point
11. **Phase 10**: Remove omarchy submodule (LAST — once everything works)
12. Test full installation on clean system
