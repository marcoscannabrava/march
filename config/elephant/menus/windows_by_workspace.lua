--
-- Window switcher grouped by workspace (Hyprland) for Elephant/Walker
--
-- Lists all open windows ordered by workspace id (special workspaces last),
-- most-recently-focused first within each workspace. Each workspace starts
-- with a non-actionable header row. Launch with:
--   walker -m menus:windowsbyworkspace
--
Name = "windowsbyworkspace"
NamePretty = "Windows"
HideFromProviderlist = true
FixedOrder = true
Icon = "view-restore"

local function get_clients()
  local handle = io.popen("hyprctl clients -j 2>/dev/null")
  if not handle then
    return {}
  end

  local raw = handle:read("*a")
  handle:close()

  if not raw or raw == "" then
    return {}
  end

  local ok, clients = pcall(jsonDecode, raw)
  if not ok or type(clients) ~= "table" then
    return {}
  end

  return clients
end

local function workspace_label(ws)
  ws = ws or {}
  if ws.id and ws.id > 0 then
    return "Workspace " .. tostring(ws.id)
  end
  return (ws.name or "special"):gsub("special:", "special: ")
end

local function workspace_sort_key(ws)
  ws = ws or {}
  if ws.id and ws.id > 0 then
    return 0, ws.id, ws.name or ""
  end
  return 1, math.huge, ws.name or "special"
end

local function same_workspace(a, b)
  local akind, aid, aname = workspace_sort_key(a)
  local bkind, bid, bname = workspace_sort_key(b)
  return akind == bkind and aid == bid and aname == bname
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Hyprland reports a window's class, which is only accidentally a valid icon
-- name: "slack" and "Alacritty" happen to match, but VS Code's class is "code"
-- while its icon is "vscode". Rebuild the class -> icon mapping from the
-- installed desktop files, the way elephant's built-in windows provider does.
local function desktop_dirs()
  local home = os.getenv("HOME") or ""

  local data_home = os.getenv("XDG_DATA_HOME")
  if data_home == nil or data_home == "" then
    data_home = home .. "/.local/share"
  end

  local data_dirs = os.getenv("XDG_DATA_DIRS")
  if data_dirs == nil or data_dirs == "" then
    data_dirs = "/usr/local/share:/usr/share"
  end

  local dirs = {data_home .. "/applications"}
  for dir in data_dirs:gmatch("[^:]+") do
    table.insert(dirs, dir .. "/applications")
  end
  table.insert(dirs, data_home .. "/flatpak/exports/share/applications")
  table.insert(dirs, "/var/lib/flatpak/exports/share/applications")

  return dirs
end

local function build_icon_index()
  local index = {by_wmclass = {}, by_basename = {}, by_host = {}}

  local globs = {}
  for _, dir in ipairs(desktop_dirs()) do
    -- glob stays outside the quotes so the shell still expands it
    table.insert(globs, shell_quote(dir) .. "/*.desktop")
  end

  local handle = io.popen("grep -sH -E '^(Icon|StartupWMClass|Exec)=' " ..
    table.concat(globs, " ") .. " 2>/dev/null")
  if not handle then
    return index
  end

  local files = {}
  local order = {}

  for line in handle:lines() do
    local path, key, value = line:match("^(.-):([%w]+)=(.*)$")
    if path and value ~= "" then
      local file = files[path]
      if not file then
        file = {wmclasses = {}}
        files[path] = file
        table.insert(order, path)
      end

      -- keep the first Icon=/Exec= only: desktop actions repeat both keys, and
      -- the [Desktop Entry] group always comes first
      if key == "Icon" then
        file.icon = file.icon or value
      elseif key == "Exec" then
        file.exec = file.exec or value
      elseif key == "StartupWMClass" then
        table.insert(file.wmclasses, value)
      end
    end
  end

  handle:close()

  for _, path in ipairs(order) do
    local file = files[path]
    if file.icon then
      for _, class in ipairs(file.wmclasses) do
        index.by_wmclass[class] = index.by_wmclass[class] or file.icon
        local lowered = class:lower()
        index.by_wmclass[lowered] = index.by_wmclass[lowered] or file.icon
      end

      local basename = path:match("([^/]+)%.desktop$")
      if basename then
        basename = basename:lower()
        index.by_basename[basename] = index.by_basename[basename] or file.icon
      end

      -- web apps launch as `browser --app=<url>` and carry no StartupWMClass,
      -- so key them by the url host instead
      if file.exec then
        local host = file.exec:match("https?://([^/%s\"']+)")
        if host then
          index.by_host[host] = index.by_host[host] or file.icon
        end
      end
    end
  end

  return index
end

local function normalize_icon(icon)
  if icon:sub(1, 1) == "/" then
    return icon
  end
  -- gtk resolves icon names, not filenames
  for _, ext in ipairs({".png", ".svg", ".xpm"}) do
    if icon:sub(-#ext):lower() == ext then
      return icon:sub(1, #icon - #ext)
    end
  end

  return icon
end

local function resolve_icon(index, class)
  if class == nil or class == "" then
    return nil
  end

  local icon = index.by_wmclass[class] or
      index.by_wmclass[class:lower()] or
      index.by_basename[class:lower()]

  if not icon then
    -- chrome names app windows "chrome-<host>__-Default"
    local host = class:match("^chrome%-(.-)__")
    if host then
      icon = index.by_host[host]
    end
  end

  -- unknown apps keep the previous behaviour of trying the class as-is
  return normalize_icon(icon or class)
end

local function workspace_value(ws)
  ws = ws or {}
  if ws.id and ws.id > 0 then
    return tostring(ws.id)
  end
  return (ws.name or "special"):gsub("^special:", "")
end

local function workspace_action(ws)
  ws = ws or {}
  if ws.id and ws.id > 0 then
    return "hyprctl dispatch workspace " .. workspace_value(ws)
  end

  local name = workspace_value(ws)
  if name == "" or name == "special" then
    return "hyprctl dispatch togglespecialworkspace"
  end
  return "hyprctl dispatch togglespecialworkspace " .. shell_quote(name)
end

function GetEntries(query)
  local clients = get_clients()
  local icons = build_icon_index()

  table.sort(clients, function(a, b)
    local akind, aid, aname = workspace_sort_key(a.workspace)
    local bkind, bid, bname = workspace_sort_key(b.workspace)

    if akind ~= bkind then
      return akind < bkind
    end
    if aid ~= bid then
      return aid < bid
    end
    if aname ~= bname then
      return aname < bname
    end
    return (a.focusHistoryID or 0) < (b.focusHistoryID or 0)
  end)

  local entries = {}
  local current_workspace = nil
  local workspace_keywords = {}
  local workspace_start = 0

  local function add_workspace_header()
    if not current_workspace then
      return
    end

    table.insert(entries, workspace_start, {
      Text = workspace_label(current_workspace),
      Subtext = "Windows",
      Keywords = workspace_keywords,
      State = {"workspace-header"},
      Value = workspace_value(current_workspace),
      Actions = {
        activate = workspace_action(current_workspace),
      },
    })
  end

  for _, c in ipairs(clients) do
    if current_workspace == nil or not same_workspace(current_workspace, c.workspace) then
      add_workspace_header()
      current_workspace = c.workspace or {}
      workspace_keywords = {workspace_label(current_workspace)}
      workspace_start = #entries + 1
    end

    local title = c.title
    if title == nil or title == "" then
      title = c.class
    end

    table.insert(workspace_keywords, title or "")
    table.insert(workspace_keywords, c.class or "")
    table.insert(entries, {
      Text = title,
      Subtext = workspace_label(c.workspace) .. " · " .. (c.class or ""),
      Icon = resolve_icon(icons, c.class),
      Value = c.address,
      Actions = {
        activate = "hyprctl dispatch focuswindow address:%VALUE%",
      },
    })
  end

  add_workspace_header()
  return entries
end
