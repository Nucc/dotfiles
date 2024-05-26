return {
  {
    "kassio/neoterm",
    config = function()
      vim.keymap.set("n", "<leader>rt", "<cmd>vert T bundle exec mtest %:line('.')<CR>")
    end,
  },
}
