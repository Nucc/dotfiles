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
vim.api.nvim_set_keymap("n", "<leader>bn", ":enew<CR>", { desc = "New buffer", noremap = true })

vim.api.nvim_set_keymap("n", "<C-M-Up>", ":m .-2<CR>==", { desc = "Move selection up", noremap = true })
vim.api.nvim_set_keymap("n", "<C-M-Down>", ":m .+1<CR>==", { desc = "Move selection down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection Down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection Up", noremap = true })

vim.api.nvim_set_keymap("n", "<C-/>", "gcc<CR>", { desc = "Comment out the line", noremap = false })
vim.api.nvim_set_keymap("v", "<C-/>", "gc<CR>", { desc = "Comment the selection", noremap = false })

vim.api.nvim_set_keymap(
  "n",
  "<leader>cp",
  ':let @+ = substitute(expand("%:p"), getcwd() .. "/", "", "")<CR>',
  { desc = "Copy the location of the current file", noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>dd", '"_dd', { desc = "Remove line into null register", noremap = false })
vim.api.nvim_set_keymap("n", "D", '"_d', { desc = "Remove line into null register", noremap = false })
vim.api.nvim_set_keymap("v", "D", '"_d', { desc = "Remove line into null register", noremap = false })

-- # CMD-A
vim.api.nvim_set_keymap("n", "+[1;1A", "ggVG", { noremap = true, silent = true })
-- # CMD-S
vim.api.nvim_set_keymap("n", "+[1;19S", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;19S", "<Esc>:w<CR>", { noremap = true, silent = true })

-- # CMD-/
vim.api.nvim_set_keymap("n", "+[1;27A", "gcc", { noremap = false, silent = true })
vim.api.nvim_set_keymap("i", "+[1;27A", "<Esc>gcc", { noremap = false, silent = true })

-- CMD-C
vim.api.nvim_set_keymap("n", "+[1;3C", "yy", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;3C", "y", { noremap = true, silent = true })

-- CMD-D
vim.api.nvim_set_keymap("i", "+[1;4D", '<Esc>"_dd', { desc = "Remove line into null register", noremap = false })
vim.api.nvim_set_keymap("n", "+[1;4D", '"_dd', { desc = "Remove line into null register", noremap = false })
vim.api.nvim_set_keymap("v", "+[1;4D", '"_d', { desc = "Remove line into null register", noremap = false })

-- CMD-N
vim.api.nvim_set_keymap("i", "+[1;14N", "<Esc>:enew<CR>", { desc = "Remove line into null register", noremap = false })
vim.api.nvim_set_keymap("n", "+[1;14N", ":enew<CR>", { noremap = false, silent = true })
vim.api.nvim_set_keymap("v", "+[1;14N", ":enew<CR>", { noremap = false, silent = true })

-- CMD-P
vim.api.nvim_set_keymap("n", "+[1;16P", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;16P", "<Esc>:Telescope find_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;16P", "<Esc>:Telescope find_files<CR>", { noremap = true, silent = true })

-- CMD-W
vim.api.nvim_set_keymap("n", "+[1;23W", ":bd<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;23W", "<Esc>:bd<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;23W", "<Esc>:bd<CR>", { noremap = true, silent = true })

-- CMD-SHIFT-F
vim.api.nvim_set_keymap("n", "+[1;32F", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;32F", "<Esc>:Telescope live_grep<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;32F", "<Esc>:Telescope live_grep<CR>", { noremap = true, silent = true })

-- CMD-Z
vim.api.nvim_set_keymap("n", "+[1;26Z", "u", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;26Z", "<Esc>u", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;26Z", "<Esc>u", { noremap = true, silent = true })

-- CMD-SHIFT-D
vim.api.nvim_set_keymap("n", "+[1;30D", '"-yy"-p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;30D", '<Esc>"-yy"-p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;30D", '<Esc>"-yy"-p', { noremap = true, silent = true })

-- CMD-{
vim.api.nvim_set_keymap("n", "+[1;102{", ":b#<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "+[1;102{", "<Esc>:b#<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;102{", "<Esc>:b#<CR>", { noremap = true, silent = true })

-- CMD-{
vim.api.nvim_set_keymap("i", "+[1;102{", "<Esc>:bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;102{", "<Esc>:bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "+[1;102{", "<Esc>:bnext<CR>", { noremap = true, silent = true })
