return {
  "tpope/vim-obsession",
  lazy = false, -- Load immediately to ensure session management is available
  config = function()
    -- Set custom session directory
    vim.g.obsession_dir = vim.fn.expand("~/.config/nvim/sessions/")

    -- Auto-save session when leaving Neovim
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        -- Only save if we're in a session that exists
        if vim.fn.exists("ThisSession") == 1 then
          vim.cmd("Obsession")
        end
      end,
    })

    -- Keybindings for session management
    vim.keymap.set("n", "<leader>ss", function()
      vim.cmd("Obsession")
    end, { desc = "Save session" })

    vim.keymap.set("n", "<leader>sl", function()
      local session_file = vim.fn.input("Session file: ", vim.g.obsession_dir, "file")
      if session_file ~= "" then
        vim.cmd("Obsession " .. session_file)
      end
    end, { desc = "Load session" })

    vim.keymap.set("n", "<leader>sq", function()
      vim.cmd("Obsession!")
    end, { desc = "Stop session tracking" })
  end,
}