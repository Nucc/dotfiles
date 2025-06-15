return {
  "greggh/claude-code.nvim",
  config = function()
    require("claude-code").setup({
      -- Toggle Claude Code terminal with this key
      toggle_key = "<leader>cc",
      -- Additional arguments to pass to Claude Code CLI
      claude_args = {},
      -- Terminal configuration
      terminal = {
        -- Terminal size (0.0 to 1.0)
        size = 0.5,
        -- Terminal position: "horizontal", "vertical", "float"
        position = "horizontal",
      },
      -- Auto-reload files modified by Claude Code
      auto_reload = true,
    })
    
    -- Set up key mappings
    vim.keymap.set("n", "<leader>cc", function()
      require("claude-code").toggle()
    end, { desc = "Toggle Claude Code terminal" })
    
    vim.keymap.set("n", "<leader>cn", function()
      require("claude-code").new_session()
    end, { desc = "Start new Claude Code session" })
  end,
}