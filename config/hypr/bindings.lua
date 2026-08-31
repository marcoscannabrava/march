-- Personal keybindings, loaded after Omarchy defaults.
-- List current bindings: omarchy menu keybindings --print

-- Terminals
hl.unbind("SUPER + ALT + RETURN") -- was: tmux Work session
o.bind("SUPER + ALT + RETURN", "Tmux", "omarchy-launch-terminal tmux new")
hl.unbind("SUPER + T") -- was: toggle floating
o.bind("SUPER + T", "Terminal", { launch = "xdg-terminal-exec" })

-- Apps
o.bind("SUPER + E", "File manager", { launch = "nautilus --new-window" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ESCAPE", "Activity", { tui = "btop" })
hl.unbind("SUPER + S") -- was: toggle scratchpad
o.bind("SUPER + S", "Slack", { launch = "slack" })
o.bind("SUPER + N", "Notes", "code ~/code/notes")

-- Web apps
hl.unbind("SUPER + SHIFT + G") -- was: Signal
o.bind("SUPER + SHIFT + G", "Google AI Studio", { webapp = "https://aistudio.google.com" })
hl.unbind("SUPER + SHIFT + W") -- was: Omawrite
o.bind("SUPER + SHIFT + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- Notifications
o.bind_toggle("SUPER + M", "Toggle silencing notifications", "notification-silencing")
hl.unbind("SUPER + ESCAPE") -- was: system menu
o.bind("SUPER + ESCAPE", "Dismiss all notifications", "omarchy-shell notifications dismissAll")

-- App switcher
hl.unbind("SUPER + TAB") -- was: next workspace
o.bind("SUPER + TAB", "App switcher", "omarchy-shell shell toggle marcos.app-switcher")

-- Window and session actions
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("ALT + F4", "Close window", hl.dsp.window.close())
o.bind("SUPER + DELETE", "Exit Hyprland", hl.dsp.exit())
hl.unbind("SUPER + F") -- was: full screen
o.bind("SUPER + F", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
hl.unbind("SUPER + L") -- was: toggle workspace layout
o.bind("SUPER + L", "Lock screen", "omarchy-system-lock")

-- Extra workspaces 11 and 12
hl.unbind("SUPER + code:20") -- was: expand window left
hl.unbind("SUPER + SHIFT + code:20") -- was: shrink window up
o.bind("SUPER + code:20", "Switch to workspace 11", hl.dsp.focus({ workspace = "11" }))
o.bind("SUPER + SHIFT + code:20", "Move window silently to workspace 11", hl.dsp.window.move({ workspace = "11", follow = false }))
hl.unbind("SUPER + code:21") -- was: shrink window left
hl.unbind("SUPER + SHIFT + code:21") -- was: expand window down
o.bind("SUPER + code:21", "Switch to workspace 12", hl.dsp.focus({ workspace = "12" }))
o.bind("SUPER + SHIFT + code:21", "Move window silently to workspace 12", hl.dsp.window.move({ workspace = "12", follow = false }))

-- "Minimize" = park on workspace 13
o.bind("SUPER + CTRL + M", "Minimize window to workspace 13", hl.dsp.window.move({ workspace = "13", follow = false }))

-- Relative workspace navigation
hl.unbind("SUPER + CTRL + LEFT") -- was: grouped window focus left
hl.unbind("SUPER + CTRL + RIGHT") -- was: grouped window focus right
o.bind("SUPER + CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "r+1" }))
o.bind("SUPER + CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "r-1" }))
o.bind("SUPER + CTRL + DOWN", "First empty workspace", hl.dsp.focus({ workspace = "empty" }))
o.bind("SUPER + CTRL + ALT + RIGHT", "Move window to next workspace", hl.dsp.window.move({ workspace = "r+1" }))
o.bind("SUPER + CTRL + ALT + LEFT", "Move window to previous workspace", hl.dsp.window.move({ workspace = "r-1" }))
o.bind("SUPER + CTRL + ALT + DOWN", "Move window to empty workspace", hl.dsp.window.move({ workspace = "empty" }))

-- Resize windows
o.bind("SUPER + SHIFT + CTRL + RIGHT", "Expand window right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
o.bind("SUPER + SHIFT + CTRL + LEFT", "Shrink window left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
o.bind("SUPER + SHIFT + CTRL + UP", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
o.bind("SUPER + SHIFT + CTRL + DOWN", "Expand window down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move windows directionally
hl.unbind("SUPER + SHIFT + LEFT") -- was: swap window left
hl.unbind("SUPER + SHIFT + RIGHT") -- was: swap window right
hl.unbind("SUPER + SHIFT + UP") -- was: swap window up
hl.unbind("SUPER + SHIFT + DOWN") -- was: swap window down
o.bind("SUPER + SHIFT + LEFT", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + RIGHT", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + UP", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + DOWN", "Move window down", hl.dsp.window.move({ direction = "d" }))

-- Speech-to-text (hyprwhspr toggle mode)
o.bind("SUPER + ALT + D", "Speech-to-text", "/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record")

-- Workspace-to-monitor rules
require("hypr.workspaces")
