-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.number = false
vim.opt.relativenumber = false
vim.g.autoformat = true

-- Indent guides (snacks.nvim indent) off by default; toggle with <leader>ug
vim.g.snacks_indent = false
