-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local km = vim.keymap

-- Don't yank when single deleting
km.set("n", "x", '"_x')

-- Unset trash
km.set("n", "Q", "<nop>") -- Q
km.set("n", "K", "<nop>") -- K

-- Movement
-- Keep cursors centered while navigating half-page
km.set("n", "<C-d>", "<C-d>zz")
km.set("n", "<C-u>", "<C-u>zz")
-- Search
km.set("n", "n", "nzzzv")
km.set("n", "N", "Nzzzv")
