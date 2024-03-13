return {
  "williamboman/mason.nvim",
  opts = {
    auto_install = true,
    ensure_installed = {
      "pyright",
      "ruff-lsp",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}