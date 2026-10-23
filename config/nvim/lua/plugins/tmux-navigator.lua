-- Seamless navigation between Neovim splits and tmux panes with Ctrl+h/j/k/l
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    -- mode n = normal (editor), mode t = terminal-insert (e.g. inside Claude Code)
    { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
    { "<c-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "t" } },
    { "<c-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "t" } },
    { "<c-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" } },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "t" } },
  },
}
