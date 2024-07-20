-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--

local function map(mode, key, command, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, key, command, options)
end

-- Function to check if current buffer is Neotree
local function is_neotree_buffer()
  local buftype = vim.api.nvim_buf_get_option(0, "filetype")
  return buftype == "neo-tree"
end

-- Function to set keybinding only for Neotree buffers
local function set_neotree_keybindings()
  if is_neotree_buffer() then
    vim.api.nvim_buf_set_keymap(0, "n", "¤[1;41O", "<Cmd>Neotree close<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", "¤[1;110E", "<Cmd>Neotree action=split<CR>", { noremap = true, silent = true })
  end
end

vim.api.nvim_create_augroup("NeotreeKeybindings", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = "NeotreeKeybindings",
  pattern = "*",
  callback = set_neotree_keybindings,
})

vim.api.nvim_set_keymap("n", "<Del>", '"_x', { noremap = false })
vim.api.nvim_set_keymap("v", "<Del>", '"_d', { noremap = false })
vim.api.nvim_set_keymap("n", "<BS>", '"_X', { noremap = true })
vim.api.nvim_set_keymap("v", "<BS>", '"_d', { noremap = true })
-- vim.keymap.set("n", "<C-M-l>", ":lua ToggleLineNumbers()<CR>", { noremap = true, silent = false })
vim.api.nvim_set_keymap(
  "n",
  "<leader>cL",
  ":lua ToggleLineNumbers()<CR>",
  { desc = "Toggle relative and absolute line numbers", noremap = true }
)
vim.api.nvim_set_keymap("n", "¤[1;38L", ":lua ToggleLineNumbers()<CR>", { noremap = false, silent = true })

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
map("n", "¤[1;1A", "ggVG")
map("i", "¤[1;1A", "<Esc>ggVG")
map("v", "¤[1;1A", "<Esc>ggVG")

vim.api.nvim_set_keymap("n", "¤[1;1A", "ggVG", {})

-- CMD-S
map("n", "¤[1;19S", ":w<CR>")
map("i", "¤[1;19S", "<Esc>:w<CR>")
map("v", "¤[1;19S", "<Esc>:w<CR>")

-- CMD-/
map("n", "¤[1;53/", "gcc", { noremap = false })
map("i", "¤[1;53/", "<Esc>gcc", { noremap = true })
map("v", "¤[1;53/", "gcc", { noremap = false })

-- CMD-C
map("n", "¤[1;3C", "yy'[")
map("v", "¤[1;3C", "y'[")

-- CMD-D
map("i", "¤[1;4D", '<Esc>"_dd')
map("n", "¤[1;4D", '"_dd')
map("v", "¤[1;4D", '"_d')

-- CMD-N
map("i", "¤[1;14N", "<Esc>:enew<CR>")
map("n", "¤[1;14N", ":enew<CR>")
map("v", "¤[1;14N", ":enew<CR>")

-- CMD-P
map("n", "¤[1;16P", ":Telescope find_files<CR>")
map("v", "¤[1;16P", "<Esc>:Telescope find_files<CR>")
map("i", "¤[1;16P", "<Esc>:Telescope find_files<CR>")

-- CMD-W
map("n", "23W", ":bd<CR>")
map("v", "¤[1;23W", "<Esc>:bd<CR>")
map("i", "¤[1;23W", "<Esc>:bd<CR>")

-- CMD-SHIFT-F
map("n", "¤[1;32F", ":Telescope live_grep<CR>")
map("v", "¤[1;32F", "<Esc>:Telescope live_grep<CR>")
map("i", "¤[1;32F", "<Esc>:Telescope live_grep<CR>")

-- CMD-Z
map("n", "¤[1;26Z", "u")
map("v", "¤[1;26Z", "<Esc>u")
map("i", "¤[1;26Z", "<Esc>u")

-- CMD-SHIFT-Z
map("n", "¤[1;52Z", "<cmd>redo<CR>")
map("v", "¤[1;52Z", "<Esc><cmd>redo<CR>")
map("i", "¤[1;52Z", "<Esc><cmd>redo<CR>")

-- CMD-SHIFT-D
map("n", "¤[1;30D", '"-yy"-p')
map("v", "¤[1;30D", '<Esc>"-yy"-p')
map("i", "¤[1;30D", '<Esc>"-yy"-p')

-- CMD-{
map("n", "¤[1;102{", ":bp<CR>")
map("v", "¤[1;102{", "<Esc>:bp<CR>")
map("i", "¤[1;102{", "<Esc>:bp<CR>")

-- CMD-}
map("i", "¤[1;103}", "<Esc>:bnext<CR>")
map("n", "¤[1;103}", ":bnext<CR>")
map("v", "¤[1;103}", "<Esc>:bnext<CR>")

-- CMD-SHIFT-<
map("i", "¤[1;104<", "<Esc><<")
map("n", "¤[1;104<", "<<")
map("v", "¤[1;104<", "<<")

-- CMD-SHIFT->
map("i", "¤[1;105>", "<Esc>>>")
map("n", "¤[1;105>", ">>")
map("v", "¤[1;105>", ">>")

-- CMD-OPT-Down
map("n", "¤[1;106D", "<cmd>lua vim.lsp.buf.definition()<CR>")

-- CMD-OPT-Down (with leader)
map("n", "¤[1;45S", "<leader>sw")

-- CMD-Up
map("v", "¤[1;107D", "G")
map("i", "¤[1;107D", "<Esc>G")
map("n", "¤[1;107D", "G")

-- CMD-Down
map("v", "¤[1;109U", "gg")
map("i", "¤[1;109U", "<Esc>gg")
map("n", "¤[1;109U", "gg", { noremap = false })

-- Neotree reveal
map("n", "¤[1;41O", "<cmd>Neotree filesystem reveal left<CR>")
map("v", "¤[1;41O", "<cmd>Neotree filesystem reveal left<CR>")
map("i", "¤[1;41O", "<Esc>:Neotree filesystem reveal left<CR>")

-- Custom command
map("n", "¤[1;29C", '<cmd>let @+ = substitute(expand("%:p"), getcwd() .. "/", "", "")<CR>')
map("i", "¤[1;29C", '<Esc><cmd>let @+ = substitute(expand("%:p"), getcwd() .. "/", "", "")<CR>')

map("n", "¤[1;110E", "o<Esc>", { noremap = false })
map("i", "¤[1;110E", "<Esc>o", { noremap = false })
map("n", "¤[1;111E", "O<Esc>", { noremap = false })
map("i", "¤[1;111E", "<Esc>O", { noremap = false })

map("i", "¤[1;112B", '<Esc>l"_di', { noremap = false })
map("n", "¤[1;112B", '"_d^', { noremap = false })

map("i", "¤[1;114D", '<Esc>l"_d$a', { noremap = false })
map("n", "¤[1;114D", '"_d$', { noremap = false })
