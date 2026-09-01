-- Personal look'n'feel overrides
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 0,
    snap = {
      enabled = true,
    },
  },
  decoration = {
    rounding = 2,
    rounding_power = 2,
  },
})

-- Custom animation curves and speeds
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "once" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

-- Small title bars on terminal windows.
-- Terminals open as locked single-window groups, so the groupbar renders as a title bar. Locked groups draw the locked_* colors.
hl.config({
  group = {
    groupbar = {
      disable_when_only = false,
      height = 14,
      font_size = 14,
      col = {
        locked_active = "rgba(008277ff)",
      },
    },
  },
})

o.window("^(Alacritty|kitty|com\\.mitchellh\\.ghostty|foot)$", { group = "new lock" })

-- Floating utility windows
o.window("nwg-displays", { float = true, center = true, size = { 920, 800 } })
o.window("org.gnome.clocks", { float = true, center = true, size = { 500, 500 } })

-- Slack lives on workspace 10
o.window("slack", { workspace = "10" })
