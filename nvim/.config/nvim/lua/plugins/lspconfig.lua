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
