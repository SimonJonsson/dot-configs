-- Personal keybindings. Omarchy's default bindings are disabled
-- (omarchy_default_bindings = false in hyprland.lua), so this file is the
-- complete, authoritative set.
--
-- Global modifier is ALT (not SUPER). Window focus is on the home row:
--   ALT+H left   ALT+J down   ALT+K up   ALT+L right
-- Terminal is ALT+RETURN; the Omarchy menu is ALT+SPACE.
--
-- Convention:
--   ALT + key              primary action
--   ALT + SHIFT + key      move / launcher
--   ALT + CTRL + key       utility / panel
--   ALT + SHIFT + CTRL + key  rare / disambiguation
-- Exception: clipboard copy/paste stays on SUPER (SUPER+C / SUPER+V) for
-- muscle memory; ALT+C / ALT+V open the clipboard history instead.
--
-- Keys marked "was SUPER+..." moved because the literal SUPER->ALT port
-- collided with another binding (ALT is both the base mod and, formerly, a
-- secondary mod, so several chords merged).

-- =====================================================================
-- Universal clipboard
-- =====================================================================
-- Send with explicit mods to the focused surface by omitting the window
-- target, so universal shortcuts reach both normal windows and focused
-- layer-shell surfaces. A virtual keyboard won't do: the physically held
-- modifier merges into the injected chord at the seat. The down/up split
-- works around Hyprland send_shortcut leaving synthetic key state stuck.
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      send_shortcut_once(terminal_mods, terminal_key)()
    else
      send_shortcut_once(default_mods, default_key)()
    end
  end
end

o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
o.bind("SUPER + V", "Universal paste", universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
o.bind("ALT + X", "Universal cut", send_shortcut_once("CTRL", "X"))
o.bind("ALT + C", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")
o.bind("ALT + V", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- =====================================================================
-- Window focus (home row)
-- =====================================================================
-- H/J/K/L move focus directionally. There used to be a "monocle" branch here,
-- but monocle is not a real layout: Hyprland only has dwindle, master and
-- scrolling, and workspace_rule accepts unknown names silently, so the test
-- never matched. Grouped windows are cycled with their own binding instead.
local function focus_or_page(direction)
  return function()
    hl.dispatch(hl.dsp.focus({ direction = direction }))
  end
end

o.bind("ALT + H", "Focus on left window", focus_or_page("l"))
o.bind("ALT + L", "Focus on right window", focus_or_page("r"))
o.bind("ALT + K", "Focus on above window", focus_or_page("u"))
o.bind("ALT + J", "Focus on below window", focus_or_page("d"))

-- =====================================================================
-- Window management
-- =====================================================================
o.bind("ALT + W", "Close window", hl.dsp.window.close())
o.bind("CTRL + ALT + DELETE", "Close all windows", "omarchy-hyprland-window-close-all")
o.bind("ALT + E", "Toggle window split", hl.dsp.layout("togglesplit")) -- was SUPER+J
o.bind("ALT + P", "Pseudo window", hl.dsp.window.pseudo())
o.bind("ALT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("ALT + CTRL + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")
o.bind("ALT + SHIFT + CTRL + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" })) -- was SUPER+ALT+F
o.bind("ALT + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
o.bind("ALT + SHIFT + Home", "Save window width", "omarchy-hyprland-window-width save") -- was SUPER+ALT+Home
o.bind("ALT + Home", "Restore window width", "omarchy-hyprland-window-width restore")
-- Toggle the active workspace between dwindle and scrolling.
-- Replaces omarchy-hyprland-workspace-layout-toggle with the same
-- dwindle/scrolling pair, but persists per-workspace the same way the
-- original does (restored by default.hypr.workspace-layouts).
o.bind("ALT + I", "Toggle workspace layout (scrolling/dwindle)", function()
  local ws = hl.get_active_workspace()
  if not ws then
    return
  end

  local id = tostring(ws.id)
  local new
  if ws.tiled_layout == "dwindle" then
    new = "scrolling"
  elseif ws.tiled_layout == "scrolling" then
    new = "dwindle"
  else
    new = "scrolling" -- anything unrecognised lands on the default
  end

  local dir = (os.getenv("HOME") or "") .. "/.local/state/omarchy/workspace-layouts"
  os.execute("mkdir -p " .. dir)
  local file = io.open(dir .. "/" .. id .. ".lua", "w")
  if file then
    file:write(string.format('hl.workspace_rule({ workspace = "%s", layout = "%s" })\n', id, new))
    file:close()
  end

  hl.workspace_rule({ workspace = id, layout = new })
  hl.exec_cmd(('omarchy-notification-send -g 󱂬 "Workspace layout set to %s"'):format(new))
end)

-- =====================================================================
-- Workspaces
-- =====================================================================
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("ALT + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("ALT + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("ALT + CTRL + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false })) -- was SUPER+SHIFT+ALT
end

-- Music lives in its own scratchpad, alongside special:scratchpad on ALT+S.
-- Hyprland allows any number of special:<name> workspaces. It is summoned over
-- whatever is on screen rather than navigated to, so it deliberately does not
-- appear in the bar: the workspaces widget only renders ids 1-10 and every
-- special workspace has a negative id. Spotify is pinned here by a window rule
-- in hyprland.lua, so ALT+CTRL+M lands in it wherever it is launched from.
o.bind("ALT + M", "Toggle music scratchpad", hl.dsp.workspace.toggle_special("music"))
o.bind("ALT + SHIFT + M", "Move window to music scratchpad", hl.dsp.window.move({ workspace = "special:music", follow = false }))

o.bind("ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("ALT + CTRL + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })) -- was SUPER+ALT+S

o.bind("ALT + Next", "Next workspace", hl.dsp.focus({ workspace = "e+1" })) -- was SUPER+TAB (Page Down)
o.bind("ALT + Prior", "Previous workspace", hl.dsp.focus({ workspace = "e-1" })) -- was SUPER+SHIFT+TAB (Page Up)
o.bind("ALT + SHIFT + Next", "Former workspace", hl.dsp.focus({ workspace = "previous" })) -- was SUPER+CTRL+TAB

o.bind("ALT + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("ALT + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("ALT + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("ALT + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

o.bind("ALT + SHIFT + CTRL + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("ALT + SHIFT + CTRL + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("ALT + SHIFT + CTRL + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("ALT + SHIFT + CTRL + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

-- =====================================================================
-- Window cycling & monitors
-- =====================================================================
o.bind("ALT + TAB", "Focus on next window", hl.dsp.window.cycle_next())
o.bind("ALT + SHIFT + TAB", "Focus on previous window", hl.dsp.window.cycle_next({ next = false }))
o.bind("ALT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
o.bind("ALT + SHIFT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
o.bind("CTRL + ALT + TAB", "Focus on next monitor", hl.dsp.focus({ monitor = "+1" }))
o.bind("CTRL + ALT + SHIFT + TAB", "Focus on previous monitor", hl.dsp.focus({ monitor = "-1" }))

-- =====================================================================
-- Resize (dropped the +-25 "a little" tier; base = +-100, CTRL = +-300)
-- =====================================================================
o.bind("ALT + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("ALT + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("ALT + SHIFT + code:20", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("ALT + SHIFT + code:21", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
o.bind("ALT + CTRL + code:20", "Expand window left a lot", hl.dsp.window.resize({ x = -300, y = 0, relative = true }))
o.bind("ALT + CTRL + code:21", "Shrink window left a lot", hl.dsp.window.resize({ x = 300, y = 0, relative = true }))
o.bind("ALT + SHIFT + CTRL + code:20", "Shrink window up a lot", hl.dsp.window.resize({ x = 0, y = -300, relative = true }))
o.bind("ALT + SHIFT + CTRL + code:21", "Expand window down a lot", hl.dsp.window.resize({ x = 0, y = 300, relative = true }))

o.bind("ALT + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.bind("ALT + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))
o.bind("ALT + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("ALT + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- =====================================================================
-- Window grouping ("switch to group window N" dropped: cycle with ALT+CTRL+GRAVE)
-- =====================================================================
-- ALT + G groups the focused window (ordinary Hyprland behaviour, so several
-- groups can coexist on a workspace). ALT + CTRL + G groups *every* tiled
-- window into one stack, and ungroups them all again.
--
-- A group is a single tile, so in dwindle a solitary group picks up
-- layout.single_window_aspect_ratio and lands centred at 16:9, exactly like a
-- lone window. (In scrolling it does not: there a group is just a column.)
local function workspace_tiled_windows(ws)
  local tiled = {}
  for _, w in ipairs(ws:get_windows()) do
    if w.mapped and not w.floating then
      tiled[#tiled + 1] = w
    end
  end
  return tiled
end

local function toggle_group_all()
  local ws = hl.get_active_workspace()
  if not ws then
    return
  end

  local tiled = workspace_tiled_windows(ws)
  if #tiled == 0 then
    return
  end

  local grouped = false
  for _, w in ipairs(tiled) do
    if w.group then
      grouped = true
    end
  end

  if grouped then
    -- group.toggle() dissolves a whole group at once, so re-scan every pass
    -- instead of toggling each window (which would build fresh groups of one).
    for _ = 1, 20 do
      local target
      for _, w in ipairs(workspace_tiled_windows(ws)) do
        if w.group then
          target = w
          break
        end
      end
      if not target then
        break
      end
      hl.dispatch(hl.dsp.focus({ window = target }))
      hl.dispatch(hl.dsp.group.toggle())
    end
    return
  end

  hl.dispatch(hl.dsp.focus({ window = tiled[1] }))
  hl.dispatch(hl.dsp.group.toggle())

  -- There is no "move into that group" dispatcher, only a direction, and the
  -- direction shifts as windows merge, so try each in turn. Test w.group on the
  -- window itself: hl.get_active_window() can still report the previously
  -- focused (already grouped) window and end the loop before anything moves.
  -- Re-scan afterwards because the shifting layout can strand a window.
  for _ = 1, 4 do
    local loose = {}
    for _, w in ipairs(workspace_tiled_windows(ws)) do
      if not w.group then
        loose[#loose + 1] = w
      end
    end
    if #loose == 0 then
      break
    end
    for _, w in ipairs(loose) do
      hl.dispatch(hl.dsp.focus({ window = w }))
      for _, dir in ipairs({ "l", "r", "u", "d" }) do
        if w.group then
          break
        end
        hl.dispatch(hl.dsp.window.move({ into_group = dir }))
      end
    end
  end
end

o.bind("ALT + G", "Toggle window grouping", hl.dsp.group.toggle())
o.bind("ALT + CTRL + G", "Group all windows on workspace", toggle_group_all)
-- The G tiers now belong entirely to grouping: ALT+G groups the focused window,
-- ALT+CTRL+G groups the whole workspace. Signal, WhatsApp and Google Messages
-- were unbound from ALT+SHIFT+G / ALT+CTRL+G / ALT+SHIFT+CTRL+G.
o.bind("ALT + CTRL + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("ALT + CTRL + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("ALT + CTRL + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("ALT + CTRL + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.bind("ALT + CTRL + GRAVE", "Next window in group", hl.dsp.group.next()) -- was SUPER+ALT+TAB
o.bind("ALT + SHIFT + CTRL + GRAVE", "Previous window in group", hl.dsp.group.prev()) -- was SUPER+ALT+SHIFT+TAB
-- Easier alias for the same cycling, on the same hand as the H/J/K/L focus keys.
-- ALT + SLASH used to be "Monitor scaling up", which moved to ALT + EQUAL.
-- Reverse stays on semicolon: ALT + SHIFT + SLASH is Passwords and was left alone.
-- (ALT + comma would pair more naturally but every comma tier is already taken
-- by the notification bindings.)
o.bind("ALT + SLASH", "Next window in group", hl.dsp.group.next())
o.bind("ALT + SHIFT + semicolon", "Previous window in group", hl.dsp.group.prev())
o.bind("ALT + LEFT", "Move grouped window focus left", hl.dsp.group.prev()) -- was SUPER+CTRL+LEFT
o.bind("ALT + RIGHT", "Move grouped window focus right", hl.dsp.group.next()) -- was SUPER+CTRL+RIGHT
o.bind("ALT + CTRL + mouse_down", "Next window in group", hl.dsp.group.next())
o.bind("ALT + CTRL + mouse_up", "Previous window in group", hl.dsp.group.prev())

o.bind("ALT + BRACKETRIGHT", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up") -- was ALT+SLASH, freed for group cycling
o.bind("ALT + CTRL + SLASH", "Monitor scaling down", "omarchy-hyprland-monitor-scaling down") -- was SUPER+ALT+SLASH

-- =====================================================================
-- Menus & bar panels
-- =====================================================================
o.bind("ALT + SPACE", "Omarchy menu", "omarchy-menu toggle") -- was SUPER+SPACE
o.bind("ALT + SHIFT + code:201", "Omarchy menu", "omarchy-menu toggle root")
o.bind("ALT + ESCAPE", "System menu", "omarchy-menu toggle system")
o.bind("XF86PowerOff", "Power menu", "omarchy-menu toggle system", { locked = true })
o.bind("ALT + U", "Keybindings", "omarchy-menu-keybindings") -- was SUPER+K
o.bind("ALT + SHIFT + U", "Tmux keybindings", "omarchy-menu-tmux-keybindings") -- was SUPER+ALT+K
o.bind("ALT + CTRL + U", "Herdr keybindings", "omarchy-menu-herdr-keybindings") -- moved off CTRL+K for move-into-group
o.bind("ALT + CTRL + Q", "Calculator", "omacalc")
o.bind("XF86Calculator", "Calculator", "omacalc")

o.bind_toggle("ALT + SHIFT + SPACE", "Toggle top bar", "bar")
o.bind("ALT + CTRL + SPACE", "Background switcher", "omarchy-menu toggle background")
o.bind("ALT + SHIFT + CTRL + SPACE", "Theme menu", "omarchy-menu toggle theme")
-- "Apps menu" (was SUPER+ALT+SPACE) dropped as a dedicated key: reachable via the Omarchy menu.

o.bind("ALT + BACKSPACE", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")
o.bind("ALT + SHIFT + BACKSPACE", "Toggle window gaps", "omarchy-hyprland-window-gaps-toggle")
o.bind("ALT + CTRL + BACKSPACE", "Toggle single-window square aspect", "omarchy-hyprland-window-single-square-aspect-toggle")

for panel = 1, 9 do
  o.bind(
    "ALT + SHIFT + CTRL + code:" .. tostring(panel + 9),
    "Bar panel " .. panel,
    "omarchy-shell -q shell togglePanelAt right " .. panel
  )
end

-- =====================================================================
-- Notifications
-- =====================================================================
o.bind("ALT + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("ALT + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
o.bind_toggle("ALT + CTRL + comma", "Toggle silencing notifications", "notification-silencing")
o.bind("ALT + SHIFT + CTRL + comma", "Open notification history", "omarchy-shell notifications showHistory")
-- "Invoke last notification" (was SUPER+ALT+comma) dropped: no free comma tier.

-- =====================================================================
-- Toggles
-- =====================================================================
o.bind_toggle("ALT + CTRL + I", "Toggle locking on idle", "idle")
o.bind_toggle("ALT + CTRL + N", "Toggle nightlight", "nightlight")
o.bind("ALT + CTRL + Delete", "Toggle laptop display", "omarchy-hyprland-monitor-internal toggle")
o.bind("ALT + SHIFT + CTRL + Delete", "Toggle laptop display mirroring", "omarchy-hyprland-monitor-internal-mirror toggle") -- was SUPER+CTRL+ALT+Delete
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

-- =====================================================================
-- Capture
-- =====================================================================
o.bind("PRINT", "Screenshot", "omarchy-capture-screenshot")
o.bind("ALT + PRINT", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")
o.bind("ALT + SHIFT + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a") -- was SUPER+PRINT
o.bind("ALT + CTRL + PRINT", "Extract text (OCR) from screenshot", "omarchy-capture-text") -- was SUPER+CTRL+PRINT
o.bind("ALT + SHIFT + S", "Screenshot (region)", "omarchy-capture-screenshot region") -- user override; was SUPER+SHIFT+S
o.bind("ALT + CTRL + code:34", "Make webcam overlay smaller", "omarchy-capture-webcam-resize smaller") -- was SUPER+ALT+code:34
o.bind("ALT + CTRL + code:35", "Make webcam overlay larger", "omarchy-capture-webcam-resize larger") -- was SUPER+ALT+code:35

-- Keyboard control for the slurp region picker. These binds live exactly as
-- long as a selection layer is on screen, so they cannot leak or get stuck.
local selection_layers = 0
local selection_binds = {}

hl.on("layer.opened", function(layer)
  if layer.namespace == "selection" then
    selection_layers = selection_layers + 1
    if selection_layers == 1 then
      selection_binds = {
        hl.bind("RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-window"), { description = "Capture highlighted window" }),
        hl.bind("CTRL + RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-fullscreen"), { description = "Capture entire screen" }),
        hl.bind("TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window next"), { description = "Select next window to capture" }),
        hl.bind("CTRL + TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window prev"), { description = "Select previous window to capture" }),
      }
      for _, direction in ipairs({ "left", "right", "up", "down" }) do
        table.insert(
          selection_binds,
          hl.bind(direction:upper(), hl.dsp.exec_cmd("omarchy-capture-region --select-window " .. direction), { description = "Select window to capture" })
        )
      end
    end
  end
end)

hl.on("layer.closed", function(layer)
  if layer.namespace == "selection" and selection_layers > 0 then
    selection_layers = selection_layers - 1
    if selection_layers == 0 then
      for _, keybind in ipairs(selection_binds) do
        keybind:unbind()
      end
      selection_binds = {}
    end
  end
end)

-- =====================================================================
-- Reminders & notices
-- =====================================================================
o.bind("ALT + CTRL + R", "Set reminder", "omarchy-menu toggle reminder-set")
o.bind("ALT + SHIFT + CTRL + R", "Show reminders", "omarchy-reminder show") -- was SUPER+CTRL+ALT+R
o.bind("ALT + SHIFT + R", "Clear reminders", "omarchy-reminder clear") -- was SUPER+SHIFT+CTRL+R

o.bind("ALT + SHIFT + CTRL + T", "Show time", "omarchy-notification-time") -- was SUPER+CTRL+ALT+T
o.bind("ALT + B", "Show battery remaining", "omarchy-notification-battery") -- was SUPER+CTRL+ALT+B; base tier (4-mod B tier taken by Browser private)
o.bind("ALT + SHIFT + CTRL + W", "Toggle weather", "omarchy-notification-weather") -- was SUPER+CTRL+ALT+W

-- =====================================================================
-- Shell panels & agent
-- =====================================================================
o.bind("ALT + CTRL + A", "Audio", "omarchy-shell shell toggle omarchy.audio")
o.bind("ALT + CTRL + B", "Bluetooth", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("ALT + CTRL + D", "Display", "omarchy-shell shell toggle omarchy.monitor")
o.bind("ALT + SHIFT + CTRL + D", "Calendar", "omarchy-shell shell toggle omarchy.clock") -- was SUPER+CTRL+ALT+D
o.bind("ALT + CTRL + W", "Network", "omarchy-shell shell toggle omarchy.network")
o.bind("ALT + CTRL + P", "Power", "omarchy-shell shell toggle omarchy.power")
o.bind("ALT + CTRL + T", "Activity", { tui = "btop" })
o.bind("ALT + SHIFT + CTRL + A", "Agent", "omarchy-agent --pick")

-- =====================================================================
-- Zoom
-- =====================================================================
o.bind("ALT + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)
o.bind("ALT + SHIFT + CTRL + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

-- "Lock system" (was SUPER+CTRL+L) dropped: lock via ALT+ESCAPE (System menu)
-- or the idle toggle (ALT+CTRL+I). Key freed for move-into-group (ALT+CTRL+L).

-- =====================================================================
-- Application launchers
-- =====================================================================
o.bind("ALT + RETURN", "Terminal", { omarchy = "terminal" }) -- was SUPER+RETURN
o.bind("ALT + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("ALT + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("ALT + PERIOD", "Emojis", "omarchy-shell shell toggle omarchy.emojis") -- was SUPER+CTRL+E
o.bind("ALT + CTRL + E", "File manager (cwd)", { omarchy = "nautilus-cwd" }) -- was SUPER+SHIFT+ALT+F
o.bind("ALT + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("ALT + SHIFT + CTRL + B", "Browser (private)", { omarchy = "browser --private" }) -- was SUPER+SHIFT+ALT+B
o.bind("ALT + SHIFT + N", "Editor", { omarchy = "editor" })

if o.preinstalled_bindings_enabled() then
  o.bind("ALT + CTRL + RETURN", "Tmux", { omarchy = "terminal-tmux" }) -- was SUPER+ALT+RETURN
  o.bind("ALT + SHIFT + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" }) -- was SUPER+CTRL+RETURN
  o.bind("ALT + CTRL + M", "Music", { omarchy = "spotify" }) -- was ALT+SHIFT+M; the window rule in hyprland.lua sends it to the music scratchpad
  o.bind("ALT + SHIFT + CTRL + M", "Music TUI", { tui = "cliamp", focus = true }) -- was SUPER+SHIFT+ALT+M
  o.bind("ALT + SHIFT + D", "Docker", { tui = "lazydocker" })
  -- Signal (was ALT+SHIFT+G) unbound: too easy to hit while grouping windows.
  -- WhatsApp (was ALT+CTRL+G) unbound: the tier now holds "group all windows".
  o.bind("ALT + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("ALT + SHIFT + W", "Omawrite", { launch = "omawrite" })
  o.bind("ALT + SHIFT + SLASH", "Passwords", { omarchy = "1password" })

  o.bind("ALT + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
  o.bind("ALT + A", "Grok", { webapp = "https://grok.com" }) -- was SUPER+SHIFT+ALT+A; base tier (CTRL+A is the Audio panel)
  o.bind("ALT + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
  o.bind("ALT + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
  o.bind("ALT + SHIFT + CTRL + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
  o.bind("ALT + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
  -- Google Messages (was ALT+SHIFT+CTRL+G) unbound: same reason as Signal.
  o.bind("ALT + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
  o.bind("ALT + SHIFT + X", "X", { webapp = "https://x.com/" })
  o.bind("ALT + SHIFT + CTRL + X", "X Post", { webapp = "https://x.com/compose/post" })
end

-- =====================================================================
-- Media, brightness, keyboard backlight, touchpad (unchanged - no SUPER)
-- =====================================================================
o.bind("XF86AudioRaiseVolume", "Volume up", "omarchy-audio-output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "omarchy-audio-output-volume lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "omarchy-audio-output-volume mute-toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "omarchy-audio-input-mute", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", "omarchy-brightness-display 100%", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", "omarchy-brightness-display 1%", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "omarchy-brightness-keyboard up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "omarchy-brightness-keyboard down", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "omarchy-brightness-keyboard cycle", { locked = true })
o.bind_toggle("XF86TouchpadToggle", "Toggle touchpad", "touchpad", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "omarchy-toggle-touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "omarchy-toggle-touchpad off", { locked = true })

o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "omarchy-audio-output-volume +1", { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "omarchy-audio-output-volume -1", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", "omarchy-brightness-display +1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", "omarchy-brightness-display 1%-", { locked = true, repeating = true })

o.bind("XF86AudioNext", "Next track", "omarchy-shell media next", { locked = true })
o.bind("ALT + XF86AudioPlay", "Next track", "omarchy-shell media next", { locked = true })
o.bind("XF86AudioPause", "Pause", "omarchy-shell media playPause", { locked = true })
o.bind("XF86AudioPlay", "Play", "omarchy-shell media playPause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "omarchy-shell media previous", { locked = true })
o.bind("ALT + SHIFT + XF86AudioPlay", "Previous track", "omarchy-shell media previous", { locked = true })
o.bind("XF86Eject", "Eject media", "eject", { locked = true })

o.bind("SHIFT + XF86AudioMute", "Switch audio output", "omarchy-audio-output-switch", { locked = true })
o.bind("SHIFT + XF86AudioPause", "Switch media source", "omarchy-audio-source-switch", { locked = true })
o.bind("SHIFT + XF86AudioPlay", "Switch media source", "omarchy-audio-source-switch", { locked = true })

-- =====================================================================
-- Dictation (only if voxtype is installed)
-- =====================================================================
if o.cmd_present("voxtype") then
  o.bind("ALT + CTRL + X", "Toggle dictation", "voxtype record toggle") -- was SUPER+CTRL+X
  o.bind("F9", "Start dictation (push-to-talk)", "voxtype record start")
  o.bind("F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })
end