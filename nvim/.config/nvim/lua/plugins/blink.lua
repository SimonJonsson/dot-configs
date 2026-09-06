return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    -- LazyVim's opts_extend *appends* to sources.default, so a plain list
    -- can't remove entries. Override after the merge instead.
    opts.sources.default = { "lsp", "path", "snippets" }

    -- show the source of each completion item in the menu
    opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
      menu = {
        draw = {
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
    })

    opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
      preset = "enter",
      ["<CR>"] = false,
      ["<C-y>"] = { "select_and_accept" },
    })

    -- Exact-prefix matches rank first; fuzzy score (incl. frecency and
    -- proximity) decides the rest; LSP sortText breaks ties.
    opts.fuzzy = vim.tbl_deep_extend("force", opts.fuzzy or {}, {
      sorts = { "exact", "score", "sort_text" },
    })

    -- Downscore snippet-shaped LSP items (rust-analyzer postfix noise like
    -- `unwr~`, `dbg~`) so real identifiers outrank them. The `snippets`
    -- source is already penalized globally by LazyVim (-3).
    opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
      providers = {
        lsp = {
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                item.score_offset = (item.score_offset or 0) - 2
              end
            end
            return items
          end,
        },
      },
    })

    return opts
  end,
}
