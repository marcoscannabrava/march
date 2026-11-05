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
o.bind("SUPER + ALT + M", "Dismiss all notifications", "omarchy-shell notifications dismissAll")

-- Power
-- SUPER + ESCAPE keeps the Omarchy default: omarchy-menu toggle system

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

-- "Minimize" = park on a special workspace
o.bind("SUPER + CTRL + M", "Minimize window", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))

-- Slot of the active workspace, or nil
local function active_slot()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.id <= 0 then
    return nil
  end
  return (workspace.id - 1) % o.workspaces.slots + 1
end

-- Lowest slot with no workspace yet
local function first_empty_slot()
  local monitor = hl.get_active_monitor()
  if not monitor then
    return nil
  end
  for slot = 1, o.workspaces.slots do
    if not hl.get_workspace(o.workspaces.workspace_id(monitor, slot)) then
      return slot
    end
  end
  return nil
end

-- Run action on slot, stay in block
local function slot_action(action, pick, ...)
  local args = { ... }
  return function()
    local slot = pick()
    if slot and slot >= 1 and slot <= o.workspaces.slots then
      action(slot, table.unpack(args))()
    end
  end
end

local function step(delta)
  return function()
    local slot = active_slot()
    return slot and slot + delta
  end
end

-- Relative navigation, inside the monitor's block
hl.unbind("SUPER + CTRL + LEFT") -- was: grouped window focus left
hl.unbind("SUPER + CTRL + RIGHT") -- was: grouped window focus right
o.bind("SUPER + CTRL + RIGHT", "Next workspace", slot_action(o.workspaces.focus, step(1)))
o.bind("SUPER + CTRL + LEFT", "Previous workspace", slot_action(o.workspaces.focus, step(-1)))
o.bind("SUPER + CTRL + DOWN", "First empty workspace", slot_action(o.workspaces.focus, first_empty_slot))
o.bind("SUPER + CTRL + ALT + RIGHT", "Move window to next workspace", slot_action(o.workspaces.move_window, step(1)))
o.bind("SUPER + CTRL + ALT + LEFT", "Move window to previous workspace", slot_action(o.workspaces.move_window, step(-1)))
o.bind("SUPER + CTRL + ALT + DOWN", "Move window to empty workspace", slot_action(o.workspaces.move_window, first_empty_slot))

-- Resize windows
hl.unbind("SUPER + SHIFT + CTRL + RIGHT") -- was: move window to right monitor
hl.unbind("SUPER + SHIFT + CTRL + LEFT") -- was: move window to left monitor
hl.unbind("SUPER + SHIFT + CTRL + UP") -- was: move window to up monitor
hl.unbind("SUPER + SHIFT + CTRL + DOWN") -- was: move window to down monitor
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
