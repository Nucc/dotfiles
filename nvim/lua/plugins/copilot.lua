return {
  "github/copilot.vim",
  config = function()
    -- Disable default Tab mapping for Copilot
    vim.g.copilot_no_tab_map = true

    -- Use Ctrl-A to accept Copilot suggestion
    vim.keymap.set('i', '<C-a>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      silent = true
    })

    -- Copilot navigation
    vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)', { silent = true })
    vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { silent = true })
    vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', { silent = true })
  end,
}
