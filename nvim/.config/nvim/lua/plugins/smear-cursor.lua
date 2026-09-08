-- Animated cursor trail, as seen in s9tpepper/dotfiles.
-- https://github.com/sphamba/smear-cursor.nvim
return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy",
	opts = {
		-- Trail when moving within a line or to a neighbouring line: this is the
		-- movement that actually shows the effect off.
		smear_between_neighbor_lines = true,

		-- Jumping between buffers/windows smears across the whole screen, which
		-- reads as noise rather than motion.
		smear_between_buffers = false,

		-- While scrolling, draw in buffer space so the trail follows the text
		-- rather than the viewport.
		scroll_buffer_space = true,

		smear_insert_mode = true,
		smear_to_cmd = false,

		-- Blends the trail more smoothly, but needs the font to carry the legacy
		-- computing symbols (U+1FB00 block). Left off until that's confirmed for
		-- JetBrainsMono Nerd Font -- turning it on without support draws boxes.
		legacy_computing_symbols_support = false,
	},
}
