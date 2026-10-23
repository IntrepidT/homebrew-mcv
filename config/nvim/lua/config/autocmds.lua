-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("claude_autoread", { clear = true, }),
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = vim.api.nvim_create_augroup("claude_filechanged", { clear = true}),
  callback = function()
    if vim.bo.modified then 
      vim.v.fcs_choice = "ask"
    else 
      vim.v.fcs_choice = "reload"
      vim.notify("Reloaded external change (Claude)", vim.log.levels.INFO)
    end
  end,
})
