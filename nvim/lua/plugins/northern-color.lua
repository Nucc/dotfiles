return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({
        diff = { mode = "bg" },
        borders = true,
        errors = { mode = "bg" },
        styles = {
          comments = { italic = true },
          keywords = {},
          functions = {},
          variables = {},
        },
        -- Override colors to match tmux background
        on_highlights = function(highlights, colors)
          highlights.Normal = { bg = "#292929" }  -- Match tmux background
          highlights.NormalFloat = { bg = "#292929" }
          highlights.SignColumn = { bg = "#292929" }
          highlights.EndOfBuffer = { bg = "#292929" }
        end,
      })
      vim.cmd.colorscheme("nord")
    end,
  },
}
