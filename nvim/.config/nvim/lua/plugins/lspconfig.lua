-- Inlay hints off by default. LazyVim enables them for every client that
-- advertises textDocument/inlayHint, which on this machine means rust-analyzer
-- reflowing lines with types and parameter names on open.
--
-- This only stops the automatic enable -- <leader>uh (Snacks.toggle.inlay_hints)
-- still turns them on for the current buffer when they are worth having.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- Diagnostics on save from clippy instead of plain `cargo check`, so
        -- the editor shows the same lints as `make lint` in the projects.
        rust_analyzer = {
          -- Use rustup's rust-analyzer component, which always matches the
          -- installed toolchain. Mason's standalone build lags behind: a 2025
          -- one against rustc 1.99 couldn't resolve std at all (every Vec,
          -- Some and .iter() undercurled as unresolved, no hover).
          -- Needs `rustup component add rust-analyzer`.
          mason = false,
          cmd = { vim.fn.expand("~/.cargo/bin/rust-analyzer") },
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy", allTargets = true },
            },
          },
        },
      },
    },
    init = function()
      -- Disable marksman's completion noise (heading snippets, document
      -- words) while keeping its other features. blink.cmp only queries
      -- clients whose server_capabilities.completionProvider is set, so
      -- clearing it on attach removes marksman from the completion sources.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "marksman" then
            client.server_capabilities.completionProvider = nil
          end
        end,
      })
    end,
  },
}
