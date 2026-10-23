return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  opts = {
    -- General
    file_types = { "markdown" },
    max_file_size = 2 * 1024 * 1024, -- skip massive files
    -- Headings: big, styled, with nice gutters
    heading = {
      enabled = true,
      sign = true,
      position = "inline", -- or "overlay"
      icons = { "H1 ", "H2 ", "H3 ", "H4 ", "H5 ", "H6 " }, -- H1..H6
      -- if your font lacks these, use simple: { "H1 ", "H2 ", ... }
    },
    -- Lists & checkboxes (visual only; state cycling is Obsidian’s job)
    checkbox = {
      enabled = false,
    },
    bullet = {
      enabled = true,
      -- glyphs for nesting levels 1,2,3…
      icons = { "- ", "* ", "+ " },
      --   left_pad = 0, -- spaces before the icon
      right_pad = 1, -- ← add a space after the icon
    },
    -- Blockquotes and rules
    quote = { enabled = true },
    horizontal_rule = { enabled = true },
    -- Code blocks with fenced headers
    code = {
      enabled = true,
      sign = true,
      style = "full", -- shows border/header; "normal" for minimal
      width = "block", -- keep it neat
    },
    -- Tables (grid lines + alignment)
    table = { enabled = true, style = "full" },
    -- Inline emphasis/strong/code conceals
    inline = { enabled = true },
    -- Math (if you write LaTeX in notes)
    latex = { enabled = false },
  },
}
