-- NOTE: Only enable either copilot-vim or codeium-vim at the same time
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

      -- Set to true to assume that copilot is already mapped
      vim.g.copilot_assume_mapped = true
      -- Set workspace folders
      vim.g.copilot_workspace_folders = "~/Repos"
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
