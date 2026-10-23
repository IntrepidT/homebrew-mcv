-- ~/.config/nvim/lua/plugins/dbee.lua
-- Database client (Go backend, Lua UI). Stock configuration.
--
-- Connections are NOT defined here: this file is tracked in git. They come from
-- the DBEE_CONNECTIONS env var, exported in ~/.zshrc.local (untracked, 0600).
-- That env var is one of dbee's OWN default sources, so no config is needed to
-- pick it up. Passwords aren't in that file either - the URLs use dbee's
-- `{{ exec ... }}` template to read them from the macOS Keychain at connect time.
--
-- Backend binary: ~/.local/share/nvim/dbee/bin/dbee (built with `go build`).
return {
  "kndndrj/nvim-dbee",
  cond = vim.env.NVIM_APPNAME ~= "mcv", -- needs my own connections + a 2GB Go build; skip on others' machines
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "Dbee",
  keys = {
    { "<leader>D", function() require("dbee").toggle() end, desc = "Dbee: toggle database client" },
  },
  build = function()
    require("dbee").install("go")
  end,
  -- LazyVim's default config handler would call require("nvim-dbee").setup(),
  -- but the module is "dbee" - so wire it explicitly. Empty setup() = all defaults.
  config = function()
    require("dbee").setup()
  end,
}
