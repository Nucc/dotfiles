return {
  {
    "filipgodlewski/luasnip-ts-snippets.nvim",
    branch = "main",
    config = function()
      local snips = require("luasnip-ts-snippets")
      snips.setup({
        -- your configuration
      })
    end,
  },
}
