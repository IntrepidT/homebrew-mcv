-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.env.PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH

-- On others' machines (mcv), keep tool caches from Mason/LSPs in mcv's cache dir so `mcv clean` removes them
if vim.env.NVIM_APPNAME == "mcv" then
  local cache = vim.fn.stdpath("cache")
  vim.env.GOPATH = cache .. "/go"
  vim.env.GOMODCACHE = cache .. "/go/pkg/mod"
  vim.env.GOCACHE = cache .. "/go/build"
  vim.env.npm_config_cache = cache .. "/npm"
  vim.env.npm_config_devdir = cache .. "/node-gyp"
  vim.env.npm_config_update_notifier = "false"
  vim.env.PIP_CACHE_DIR = cache .. "/pip"
  vim.env.PYTHONPYCACHEPREFIX = cache .. "/pycache"
end
