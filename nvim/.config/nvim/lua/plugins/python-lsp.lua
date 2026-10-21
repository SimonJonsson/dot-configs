-- Ruff owns Python diagnostics. Pyright stays attached for hover, go-to-definition
-- and completion, but reports nothing: LazyVim's lang.python extra enables both
-- servers and only silences ruff's *hover*, so every buffer otherwise carries two
-- sets of signs -- and pyright's are mostly reportMissingImports from scripts that
-- run outside a venv.
--
-- Pyright registers `textDocument/diagnostic` dynamically, so its capabilities look
-- push-only at init while it actually serves diagnostics over pull. Both routes are
-- dropped below; a client handler takes precedence over vim.lsp.handlers for the
-- push notification and over the default response handler for the pull request.
-- Ruff is untouched and keeps publishing into its own namespace.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
            ["textDocument/diagnostic"] = function() end,
            ["workspace/diagnostic"] = function() end,
          },
          -- resolve imports against whatever `python` is on PATH (active venv)
          settings = {
            python = {
              pythonPath = vim.fn.exepath("python"),
            },
          },
        },
      },
    },
  },
}
