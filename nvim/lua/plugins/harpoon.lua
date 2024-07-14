return {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("harpoon").setup({})
      require("telescope").load_extension("harpoon")

      vim.api.nvim_set_keymap("n", "<leader>..", ":Telescope harpoon marks<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap(
        "n",
        "<leader>.,",
        ':lua require("harpoon.mark").add_file()<CR>',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>.m",
        ':lua require("harpoon.ui").toggle_quick_menu()<CR>',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>.a",
        ':lua require("harpoon.ui").nav_file(1)<CR>',
        { noremap = true, silent = true }
      )

      vim.api.nvim_set_keymap(
        "n",
        "<leader>.s",
        ':lua require("harpoon.ui").nav_file(2)<CR>',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>.d",
        ':lua require("harpoon.ui").nav_file(3)<CR>',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>.f",
        ':lua require("harpoon.ui").nav_file(4)<CR>',
        { noremap = true, silent = true }
      )
    end,
  },
}
