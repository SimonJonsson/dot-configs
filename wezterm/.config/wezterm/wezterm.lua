-- Mirrors alacritty/.config/alacritty/alacritty.toml so either terminal looks
-- and behaves the same.
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night Storm"

config.font = wezterm.font_with_fallback({
	"CaskaydiaMono Nerd Font",
	"JetBrainsMono Nerd Font",
})
config.font_size = 12

-- tmux owns tabs and splits.
config.enable_tab_bar = false
config.window_padding = { left = 14, right = 14, top = 14, bottom = 14 }
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20

-- Left Option = Alt (herdr chords); right Option untouched so GO60 AltGr
-- combos (a+e etc.) compose åäö via the U.S. Swedish AltGr layout.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

config.keys = {
	{ key = "Insert", mods = "SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "Insert", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b\r") },
	-- Default fullscreen toggle would swallow Alt+Enter before herdr sees it.
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
}

config.default_prog = { "/opt/homebrew/bin/fish", "-l", "-c", "tmux attach || tmux -2" }

return config
