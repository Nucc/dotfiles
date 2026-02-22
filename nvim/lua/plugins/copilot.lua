return {
  "github/copilot.vim",
  event = "InsertEnter",  -- Lazy-load when entering insert mode
  cmd = "Copilot",        -- Also load on Copilot commands
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

    -- Auto-stop Copilot after inactivity to save memory
    local copilot_timer = nil
    local copilot_running = true  -- Assume running after initial load

    -- Function to stop copilot
    local function stop_copilot()
      if copilot_running then
        -- Try to stop the language server
        pcall(function()
          vim.cmd('Copilot disable')
        end)
        copilot_running = false
        print("Copilot stopped due to inactivity")
      end
    end

    -- Function to restart copilot
    local function start_copilot()
      if not copilot_running then
        pcall(function()
          vim.cmd('Copilot enable')
        end)
        copilot_running = true
        print("Copilot restarted")
      end
    end

    -- Stop copilot after 10 minutes of inactivity
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      callback = function()
        if copilot_timer then
          vim.fn.timer_stop(copilot_timer)
        end
        copilot_timer = vim.fn.timer_start(600000, stop_copilot) -- 10 minutes
      end
    })

    -- Restart copilot when you start typing
    vim.api.nvim_create_autocmd({"InsertEnter"}, {
      callback = start_copilot
    })
  end,
}
