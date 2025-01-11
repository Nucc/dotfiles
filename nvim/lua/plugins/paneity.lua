return {
  "bestie/paneity.nvim",
  config = function()
    require("paneity").setup({
      marker = "🥖🕹️", -- The marker string to indicate the attached pane
      split_direction = "horizontal", -- Options: "horizontal", "vertical" (nil means tmux default)
      split_size = nil, -- Number rows/columns of available space (nil means tmux default)
      split_percentage_size = nil, -- Percentage of available space, takes precendence over `split_size` (nil means tmux default)
      keybindings = { -- false to disable all keybindings
        -- set individual keybindings to false to disable
        toggle = "<leader>tp", -- Toggle on/off, on sets target pane or opens a new one
        new_command = "<leader>tc", -- Set a new command and run it in the pane
        repeat_command = "<leader><leader>", -- Re-run the last command
        page_up = "<PageUp>", -- Scroll the pane up
        page_down = "<PageDown>", -- Scroll the pane down
        up_enter = "<leader><Up>", -- Re-run via ↑ ENTER
      },
    })
  end,
}
