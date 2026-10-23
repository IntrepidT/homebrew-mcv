-- Git review stack: diffview-plus (diffview superset) + gitlab.nvim + gitsigns
-- Keymap groups:
--   <leader>gd*  Diffview
--   <leader>gm*  GitLab merge requests
--   <leader>gh*  Gitsigns hunks (LazyVim default, unchanged)

return {
  -- which-key groups so the menus read nicely
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gd", group = "diffview", icon = { icon = " ", color = "green" } },
        { "<leader>gm", group = "gitlab (MR)", icon = { icon = " ", color = "orange" } },
      },
    },
  },

  -- diffview.nvim (using the actively-maintained diffview-plus fork so it also
  -- satisfies gitlab.nvim's dependency; same :Diffview* commands and setup()).
  {
    "dlyongemallo/diffview-plus.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open (working tree vs HEAD)" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close" },
      { "<leader>gdb", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff branch vs main" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "Repo/branch file history" },
      { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
      { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true, -- richer intra-line highlighting
        view = {
          merge_tool = { layout = "diff3_mixed" }, -- 3-way view for conflicts
        },
        file_panel = {
          listing_style = "tree",
          win_config = { width = 32 },
        },
      })
    end,
  },

  -- gitlab.nvim: review/manage GitLab MRs in the editor.
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "dlyongemallo/diffview-plus.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
    cond = vim.env.NVIM_APPNAME ~= "mcv", -- needs my GitLab token + a Go build; skip on others' machines
    build = function()
      require("gitlab.server").build(true) -- compiles the Go backend
    end,
    opts = { debug = { request = true, response = true } }, -- temp: log HTTP req/resp to diagnose POST failures
    keys = {
      -- entry points
      { "<leader>gmr", function() require("gitlab").choose_merge_request() end, desc = "Review an MR (pick)" },
      { "<leader>gmR", function() require("gitlab").review() end, desc = "Review current branch MR" },
      { "<leader>gms", function() require("gitlab").summary() end, desc = "MR summary" },
      -- discussions / comments
      { "<leader>gmd", function() require("gitlab").toggle_discussions() end, desc = "Toggle discussions" },
      { "<leader>gmc", function() require("gitlab").create_comment() end, desc = "Comment on line", mode = "n" },
      { "<leader>gmc", function() require("gitlab").create_multiline_comment() end, desc = "Comment on selection", mode = "v" },
      { "<leader>gmS", function() require("gitlab").create_comment_suggestion() end, desc = "Suggest change", mode = "v" },
      { "<leader>gmn", function() require("gitlab").create_note() end, desc = "Add MR note (not on a line)" },
      -- publishing drafts
      { "<leader>gmD", function() require("gitlab").toggle_draft_mode() end, desc = "Toggle draft mode" },
      { "<leader>gmP", function() require("gitlab").publish_all_comments() end, desc = "Publish all drafts" },
      -- actions
      { "<leader>gmA", function() require("gitlab").approve() end, desc = "Approve MR" },
      { "<leader>gmV", function() require("gitlab").revoke() end, desc = "Revoke approval" },
      { "<leader>gmm", function() require("gitlab").merge() end, desc = "Merge MR" },
      { "<leader>gmp", function() require("gitlab").pipeline() end, desc = "Pipeline status" },
      { "<leader>gmb", function() require("gitlab").open_in_browser() end, desc = "Open MR in browser" },
      { "<leader>gmu", function() require("gitlab").copy_mr_url() end, desc = "Copy MR URL" },
    },
  },

  -- gitsigns is provided by LazyVim; just extend it with inline blame.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
    },
  },
}
