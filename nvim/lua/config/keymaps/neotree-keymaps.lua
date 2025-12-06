-- Function to set keybinding only for Neotree buffers
local function set_neotree_keybindings()
  -- Set buffer-local close mapping for all modes (overrides global keymap)
  local close_cmd = "<Cmd>Neotree close<CR>"
  vim.api.nvim_buf_set_keymap(0, "n", "\xF4\x80\x81\x8F", close_cmd, { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, "v", "\xF4\x80\x81\x8F", close_cmd, { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, "i", "\xF4\x80\x81\x8F", close_cmd, { noremap = true, silent = true })

  -- Split keymap
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "\xF4\x80\x83\x88",
    "<Cmd>Neotree action=split<CR>",
    { noremap = true, silent = true }
  )
end

vim.api.nvim_create_augroup("NeotreeKeybindings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "NeotreeKeybindings",
  pattern = "neo-tree",
  callback = set_neotree_keybindings,
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>cs",
  ":Neotree document_symbols<CR><C-h>",
  { desc = "Show symbols", noremap = true }
)
