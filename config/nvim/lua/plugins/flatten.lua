-- lua/plugins/flatten.lua
return {
  "willothy/flatten.nvim",
  opts = {
    -- How to open files in the host Neovim
    window = {
      -- "current"   = use the current window
      -- "alternate" = use the previously active window (nice with floating terminals)
      open = "current",
    },

    -- -- What to do when a nested Neovim would start
    -- callbacks = {
    --   -- Called when a nested session is created
    --   pre_open = function()
    --     -- You *can* do things like hide statusline/tabline here if you want
    --     -- vim.cmd("set laststatus=0")
    --   end,
    --
    --   -- Called after the file is opened in the host
    --   post_open = function(bufnr, winnr, ft)
    --     -- Example: if you want to do something based on filetype:
    --     -- if ft == "gitcommit" then
    --     --   vim.bo[bufnr].spell = true
    --     -- end
    --   end,
    --
    --   -- Called when the nested session (the "child" nvim process) exits
    --   block_end = function()
    --     -- This is where you *could* try to close the terminal that launched nvim,
    --     -- but with LazyVim / floating lazygit it's often nicer to just leave it.
    --     --
    --     -- If later you want to auto-close a specific floating term, you can:
    --     --  - track it via a custom terminal mapping, or
    --     --  - use snacks/toggleterm APIs here.
    --   end,
    -- },

    -- Optional: tweak which commands flatten should intercept
    -- By default, it already handles 'nvim' nicely.
    -- one_per = {
    --   -- e.g. "filesystem" to ensure only one filesystem tool hijacks the host at a time.
    --   -- Leaving this as default is usually fine.
    -- },
  },
}
