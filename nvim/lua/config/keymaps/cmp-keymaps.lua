cmp = require("cmp")
cmp.setup({
  experimental = {
    ghost_text = false, -- Disable ghost text preview
  },
  completion = {
    completeopt = "menu,menuone",
  },
  mapping = {
    ["<Tab>"] = cmp.mapping.confirm({ select = false }),
    ["<CR>"] = cmp.mapping(function(fallback)
      fallback() -- If no completion is selected, perform default Enter action
    end),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})
