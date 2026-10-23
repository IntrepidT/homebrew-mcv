return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          {
            "K",
            function()
              return vim.lsp.buf.hover()
            end,
            desc = "Hover",
          },
        },
      },
    },
  },
}
