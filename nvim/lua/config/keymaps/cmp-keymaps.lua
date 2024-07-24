cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    ["<CR>"] = cmp.mapping(function(fallback)
      fallback() -- If no completion is selected, perform default Enter action
    end),
  },
})
