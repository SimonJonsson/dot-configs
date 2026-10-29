-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Pick up edits made on disk by other tools (LLM agents in another pane).
-- LazyVim only runs :checktime on FocusGained, which never fires while nvim
-- stays in view, so poll once a second. autoread reloads unmodified buffers
-- silently; a buffer with unsaved changes gets nvim's usual conflict prompt.
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(1000, 1000, vim.schedule_wrap(function()
  -- :checktime is not allowed in the command-line window, and would interrupt
  -- typing on the command line or in a prompt.
  if vim.fn.getcmdwintype() ~= "" or vim.fn.mode():match("^[cr]") then
    return
  end
  vim.cmd("silent! checktime")
end))
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("checktime_on_move", { clear = true }),
  command = "silent! checktime",
})
