local opt = vim.opt

--vim.g.loaded_netrw = 1
--vim.g.netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Hybrid numbers
opt.number = true
opt.relativenumber = true

-- cursorline
opt.cursorline = true

-- tab settings
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- saving settings
opt.swapfile = false
opt.backup = false

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- set clipboard to use system
opt.clipboard = "unnamedplus"

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = "· ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
