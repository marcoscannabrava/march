-- Workspaces 1-5 on the laptop, 6-12 external.
-- Loaded by the require in bindings.lua.
for ws = 1, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1", default = ws == 1 })
end

for ws = 6, 12 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-1", default = ws == 6 })
end
