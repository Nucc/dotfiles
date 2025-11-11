return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {},
  config = function()
    require("fzf-lua").setup({
      winopts = {
        help = "", -- Disable help line
      },
      fzf_opts = {
        ["--tiebreak"] = "length,begin,index",
      },
      lsp = {
        -- Increase timeout for slow LSP servers like Solargraph
        async_or_timeout = 30000, -- 30 seconds
      },
    })
  end,
}
