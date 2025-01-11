-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

function ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end

vim.wo.relativenumber = false

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls", -- TypeScript server
    "tailwindcss", -- Tailwind CSS server
  },
})

local lspconfig = require("lspconfig")

-- Default capabilities for completion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TypeScript (tsserver) config
lspconfig.tsserver.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Additional TypeScript-specific actions if needed
  end,
})

-- Tailwind CSS
lspconfig.tailwindcss.setup({
  capabilities = capabilities,
})
