-- NOTE: Only enable either copilot-vim or codeium-vim at the same time
-- https://github.com/github/copilot.vim/blob/release/plugin/copilot.vim
return {
  -- Disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    event = "VeryLazy",
    keys = function()
      return {}
    end,
  },
  -- Setup nvim-cmp
  {
    "nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- Disable ghost text for nvim-cmp, use copilot suggestion instead
      opts.experimental.ghost_text = false
    end,
  },
  -- Setup copilot.vim
  {
    "github/copilot.vim",
    event = "VeryLazy",
    config = function()
      -- For copilot.vim
      -- enable copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
      }
      vim.g.copilot_enabled = false

      -- Set to true to assume that copilot is already mapped
      vim.g.copilot_assume_mapped = true
      -- Set workspace folders
      vim.g.copilot_workspace_folders = "~/Repos"

      -- Setup keymaps
      local keymap = vim.keymap.set
      local opts = { silent = true }

      -- Set <C-y> to accept copilot suggestion
      vim.g.copilot_no_tab_map = false
      keymap("i", "<C-f>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })

      -- Set <C-i> to accept line
      keymap("i", "<C-i>", "<Plug>(copilot-accept-line)", opts)

      -- Set <C-j> to next suggestion, <C-k> to previous suggestion, <C-l> to suggest
      keymap("i", "<C-j>", "<Plug>(copilot-next)", opts)
      keymap("i", "<C-k>", "<Plug>(copilot-previous)", opts)
      keymap("i", "<C-l>", "<Plug>(copilot-suggest)", opts)

      -- Set <C-d> to dismiss suggestion
      keymap("i", "<C-d>", "<Plug>(copilot-dismiss)", opts)

      local copilot_on = false
      vim.api.nvim_create_user_command("CopilotToggle", function()
        if copilot_on then
          vim.cmd("Copilot disable")
          print("Copilot OFF")
        else
          vim.cmd("Copilot enable")
          print("Copilot ON")
        end
        copilot_on = not copilot_on
      end, { nargs = 0 })

      keymap("n", "<leader>ac", ":CopilotToggle<CR>", { desc = "Toggle copilot", noremap = true, silent = true })
    end,
  },
  -- Add status line icon for copilot
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local Util = require("lazyvim.util")
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local icon = require("lazyvim.config").icons.kinds.Copilot
          return icon
        end,
        cond = function()
          local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot", bufnr = 0 })
          return ok and #clients > 0
        end,
        color = function()
          return Util.ui.fg("Special")
        end,
      })
    end,
  },
}
