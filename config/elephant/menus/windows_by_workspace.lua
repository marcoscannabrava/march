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
      Icon = c.class,
      Value = c.address,
      Actions = {
        activate = "hyprctl dispatch focuswindow address:%VALUE%",
      },
    })
  end

  add_workspace_header()
  return entries
end
