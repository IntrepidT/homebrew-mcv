-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Leave insert mode without reaching for Esc (saves the pinky)
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- Difftastic: structural diff in a Snacks terminal
vim.keymap.set("n", "<leader>gt", function()
  Snacks.terminal("git -c diff.external=difft diff")
end, { desc = "Difftastic (working tree)" })
vim.keymap.set("n", "<leader>gT", function()
  Snacks.terminal("git -c diff.external=difft diff HEAD~1")
end, { desc = "Difftastic (last commit)" })
