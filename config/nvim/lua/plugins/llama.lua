-- ~/.config/nvim/lua/plugins/llama.lua
-- Local, offline inline completion via llama.vim + llama.cpp.
-- Model: IBM Granite Code 3B (base), Apache-2.0, US-origin. FIM-native.
-- Server runs separately on 127.0.0.1:8012 (see the llama LaunchAgent).
-- Nothing leaves this machine: no cloud, no telemetry.
return {
  "ggml-org/llama.vim",
  lazy = false,
  init = function()
    vim.g.llama_config = {
      endpoint_fim = "http://127.0.0.1:8012/infill",
      auto_fim = false, -- disabled: Granite model missing, server down. Re-download model + set true to restore.
      show_info = 2, -- show model/latency info in the statusline area

      -- Keep <Tab> as a normal Tab; accept suggestions explicitly (your prior preference).
      keymap_fim_accept_full = "<C-y>", -- accept the whole suggestion
      keymap_fim_accept_line = "<C-j>", -- accept one line
      keymap_fim_accept_word = "<C-k>", -- accept one word
      keymap_fim_trigger = "<C-\\>", -- manually trigger / dismiss
    }
  end,
}
