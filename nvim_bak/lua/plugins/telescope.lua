return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-ui-select.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<esc>"] = require("telescope.actions").close,
							["<C-h>"] = "which_key",
						},
					},
				},
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown({}) },
				},
			})
			require("telescope").load_extension("ui-select")
			local km = vim.keymap
			local builtin = require("telescope.builtin")

			-- Search
			km.set("n", "<leader>f", builtin.find_files, {
				desc = "[F]ind file",
			})
			km.set("n", "<leader>sa", builtin.live_grep, {
				desc = "[S]earch [All]",
			})
			km.set("n", "<leader>sw", builtin.grep_string, {
				desc = "[S]earch current [W]ord",
			})
			km.set("n", "<leader>sb", builtin.buffers, {
				desc = "[S]earch [B]uffers",
			})
			km.set("n", "<leader>ss", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 0,
					previewer = false,
				}))
			end, {
				desc = "Buffer [S]earch",
			})
			km.set("n", "<leader>sk", builtin.keymaps, {
				desc = "[S]earch [K]eymaps",
			})
			km.set("n", "<leader>sf", builtin.find_files, {
				desc = "[S]earch [F]iles",
			})
			km.set("n", "<leader>sn", function()
				builtin.find_files({
					cwd = vim.fn.stdpath("config"),
				})
			end, {
				desc = "[S]earch [N]eovim files",
			})

			-- Shortcut for searching your neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({
					cwd = vim.fn.stdpath("config"),
				})
			end, {
				desc = "[S]earch [N]eovim files",
			})

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
					end
					-- LSP
					--km.set("n", "<leader>td", "<cmd>Telescope lsp_definitions<cr>", { desc = "Show definitions" })
					--km.set("n", "<leader>tr", "<cmd>Telescope lsp_references<cr>", { desc = "Show references" })

					map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					map("gr", builtin.lsp_references, "[G]oto [R]eferences")

					map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace
					--  Similar to document symbols, except searches over your whole project.
					map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

					-- Rename the variable under your cursor
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					-- Opens a popup that displays documentation about the word under your cursor
					--  See `:help K` for why this keymap
					map("K", vim.lsp.buf.hover, "Hover Documentation")
				end,
			})

			-- Other
			km.set("n", "<leader>tb", "<cmd>Telescope buffers<cr>", { desc = "Search buffers" })
			km.set("n", "<leader>th", "<cmd>Telescope help_tags<cr>", { desc = "Show help tags" })
			km.set("n", "<leader>t-", "<cmd>Telescope builtin<cr>", { desc = "Show builtin" })
		end,
	},
}
