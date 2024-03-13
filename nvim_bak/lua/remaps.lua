local km = vim.keymap

-- Don't yank when single deleting
km.set("n", "x", '"_x')

-- Unset trash
km.set("n", "Q", "<nop>") -- Q
km.set("n", "K", "<nop>") -- K

-- Easy access to commands
km.set("n", "<leader><leader>", ":", { desc = "Open command line" })
km.set("n", "<leader>e", ":w<CR>", { desc = "Write file" })
km.set("n", "<leader>q", ":bd<CR>", { desc = "Close buffer" })

-- Move stuff while highlighted
km.set("v", "J", "<nop>")
km.set("v", "J", ":m '>+1<CR>gv=gv'")
km.set("v", "K", "<nop>")
km.set("v", "K", ":m '<-2<CR>gv=gv'")

-- Movement
-- Keep cursors centered while navigating half-page
km.set("n", "<C-d>", "<C-d>zz")
km.set("n", "<C-u>", "<C-u>zz")
-- Search 
km.set("n", "n", "nzzzv")
km.set("n", "N", "Nzzzv")

-- Window management
km.set("n", "<leader>w", "<C-w>", { desc = "[W]indow" })
