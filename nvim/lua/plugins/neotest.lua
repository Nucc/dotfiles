return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "olimorris/neotest-rspec",
    -- "zidhuss/neotest-minitest",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-rspec"),
        -- require("neotest-rspec")({
        --   test_cmd = function()
        --     return "bundle exec mtest"
        --   end,
        -- }),

        -- require("neotest-minitest")({
        --   test_cmd = function()
        --     return "bundle exec mtest"
        --   end,
        -- }),
      },
    })
  end,
}
