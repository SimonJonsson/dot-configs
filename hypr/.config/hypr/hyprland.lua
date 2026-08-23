-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings; the complete set lives in
-- ~/.config/hypr/bindings.lua (global modifier = ALT, focus = H/J/K/L).
omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Keep music players in the music scratchpad (see ALT+M in bindings.lua).
-- A window rule is evaluated when a window is mapped, so this routes newly
-- launched players; anything already running has to be moved with ALT+SHIFT+M.
-- Omarchy launches TUIs with app-id org.omarchy.<command>, hence cliamp's class.
o.window("(Spotify|org\\.omarchy\\.cliamp)", { workspace = "special:music" })

-- The scratchpad inherits the global scrolling layout today; pin it so it stays
-- scrolling even if the global default changes.
hl.workspace_rule({ workspace = "special:music", layout = "scrolling" })
