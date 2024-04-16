return {
  "williamboman/mason.nvim",
  opts = {
    auto_install = true,
    ensure_installed = {
      "pyright",
      "ruff-lsp",
      "black",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
      "bicep-lsp",
    },
  },
}
