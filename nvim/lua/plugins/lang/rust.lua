return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              inlayHints = { parameterHints = false, typeHints = false },
            },
          },
        },
      },
    },
  },
}
