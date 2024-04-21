return {
  -- { "typicode/bg.nvim", lazy = false },
  -- { "xiyaowong/transparent.nvim" },
  {
    "nvim-tree/nvim-web-devicons",
    require("nvim-web-devicons").setup({
      color_icons = false,
      default = true,
      strict = true,
      override_by_extension = {
        ["lua"] = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Lua",
        },

        ["/"] = {
          icon = "",
        },
      },
    }),
  },
}
