return {

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      -- inlay hints off by default; toggle with <leader>uh
      inlay_hints = { enabled = false },
    },
  },
}
