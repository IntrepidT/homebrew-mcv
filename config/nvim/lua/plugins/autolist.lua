return {
  "gaoDean/autolist.nvim",
  ft = { "markdown" },
  opts = {},
  config = function(_, opts)
    require("autolist").setup(opts)
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<CR>", { buffer = true })
    vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<CR>", { buffer = true })
    vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<CR>", { buffer = true })
    vim.keymap.set("n", ">>", "<cmd>AutolistIndent<CR>", { buffer = true })
    vim.keymap.set("n", "<<", "<cmd>AutolistOutdent<CR>", { buffer = true })
    vim.keymap.set("n", "dd", "<cmd>AutolistDelete<CR>", { buffer = true })
  end,
}
