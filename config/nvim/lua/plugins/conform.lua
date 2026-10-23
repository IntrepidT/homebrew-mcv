return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "eslint", "prettier" },
      typescript = { "eslint", "prettier" },
      javascriptreact = { "eslint", "prettier" },
      typescriptreact = { "eslint", "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      java = { "google-java-format" },
    },
  },
}
