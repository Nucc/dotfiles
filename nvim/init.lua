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

