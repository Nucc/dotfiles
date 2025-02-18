-- Function to check if current buffer is Neotree
local function is_neotree_buffer()
  local buftype = vim.api.nvim_buf_get_option(0, "filetype")
  return buftype == "neo-tree"
end

-- Function to set keybinding only for Neotree buffers
local function set_neotree_keybindings()
  if is_neotree_buffer() then
    vim.api.nvim_buf_set_keymap(0, "n", "\xF4\x80\x81\x8F", "<Cmd>Neotree close<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", "¤[1;110E", "<Cmd>Neotree action=split<CR>", { noremap = true, silent = true })
  end
end

vim.api.nvim_create_augroup("NeotreeKeybindings", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = "NeotreeKeybindings",
  pattern = "*",
  callback = set_neotree_keybindings,
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>cs",
  ":Neotree document_symbols<CR><C-h>",
  { desc = "Show symbols", noremap = true }
)
