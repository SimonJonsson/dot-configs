-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- <leader>ul: toggle line numbers, always relative when on
vim.keymap.set("n", "<leader>ul", function()
  local on = not vim.wo.number
  vim.wo.number = on
  vim.wo.relativenumber = on
end, { desc = "Toggle Line Numbers (relative)" })
