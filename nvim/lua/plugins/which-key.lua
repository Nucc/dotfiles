-- ~/.config/nvim/lua/plugins/which-key.lua
return {
  "folke/which-key.nvim",
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      icons = {
        mappings = false,
      },
    })

    wk.register({
      ["<leader>"] = {
        f = { name = "+file" },
        p = { name = "+project" },
        s = { name = "+search" },
        g = { name = "+git" },
        t = { name = "+toggle" },
        b = { name = "+buffer" },
        w = { name = "+window" },
        h = { name = "+help" },
        q = { name = "+quit/session" },
        l = { name = "+lsp" },
        d = { name = "+debug" },
        c = { name = "+code" },
        r = { name = "+refactor" },
      },
      ["g"] = {
        name = "+goto",
        d = "Go to definition",
        D = "Go to declaration",
        p = "Go to preview definition",
        i = "Go to implementation",
        r = "Go to references",
        t = "Go to type definition",
      },
    })
  end,
}
