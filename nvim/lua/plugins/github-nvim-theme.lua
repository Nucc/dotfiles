return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 999, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        options = {
          transparent = false,
        },
      })

      vim.cmd("colorscheme github_dark_dimmed")
    end,
  },
  -- { "typicode/bg.nvim", lazy = false },
  -- { "xiyaowong/transparent.nvim" },
  -- {
  --   "nvim-tree/nvim-web-devicons",
  --   require("nvim-web-devicons").setup({
  --     -- color_icons = false,
  --     default = true,
  --     override = {
  --       any = {
  --         icon = "",
  --         color = "#428850",
  --         cterm_color = "65",
  --         name = "Zsh",
  --       },
  --     },
  --   }),
  -- },
}
