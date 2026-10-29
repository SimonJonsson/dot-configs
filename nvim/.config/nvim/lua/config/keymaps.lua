-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- <leader>ul: toggle line numbers, always relative when on
vim.keymap.set("n", "<leader>ul", function()
  local on = not vim.wo.number
  vim.wo.number = on
  vim.wo.relativenumber = on
end, { desc = "Toggle Line Numbers (relative)" })

-- Keep the cursor line centred when paging half a screen up or down
vim.keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
vim.keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
