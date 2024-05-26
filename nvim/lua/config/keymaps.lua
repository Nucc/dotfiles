-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- vim.api.nvim_set_keymap("i", "<Del>", "x", { noremap = false })

function ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end

-- vim.keymap.set("n", "<C-M-l>", ":lua ToggleLineNumbers()<CR>", { noremap = true, silent = false })
vim.api.nvim_set_keymap(
  "n",
  "<leader>cL",
  ":lua ToggleLineNumbers()<CR>",
  { desc = "Toggle relative and absolute line numbers", noremap = true }
)

vim.api.nvim_set_keymap("n", "<BS>", "X", { noremap = true })

vim.api.nvim_set_keymap(
  "n",
  "<leader>cs",
  ":Neotree document_symbols<CR><C-h>",
  { desc = "Show symbols", noremap = true }
)
vim.api.nvim_set_keymap("n", "M-l", "$", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>bn", ":enew<CR>", { desc = "New buffer", noremap = true })

vim.api.nvim_set_keymap("n", "M-S-k", ":m-1", { desc = "Move selection up", noremap = true })
vim.api.nvim_set_keymap("n", "M-S-j", ":m+1", { desc = "Move selection down", noremap = true })
