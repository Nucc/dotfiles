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
        preview = {
          title = false, -- Hide preview title
        },
      },
      fzf_opts = {
        ["--tiebreak"] = "length,begin,index",
        ["--no-info"] = "", -- Hide info line with file count
      },
      files = {
        prompt = "Files> ", -- Simple prompt without path
        cwd_prompt = false, -- Disable cwd in prompt
        header = false, -- Disable header
      },
      lsp = {
        -- Increase timeout for slow LSP servers like Solargraph
        async_or_timeout = 30000, -- 30 seconds
      },
    })
  end,
}
