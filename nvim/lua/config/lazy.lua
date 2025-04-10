local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  ui = {
    border = "rounded",
    notify = false,
  },
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- import any extras modules here
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.ruby" },
    { import = "lazyvim.plugins.extras.coding.nvim-cmp" },
    -- { import = "lazyvim.plugins.extras.coding.snippets" },
    {

      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        -- add tsx and treesitter
        vim.list_extend(opts.ensure_installed, {
          "lua",
          "typescript",
          "ruby",
          "javascript",
          "yaml",
        })
      end,
    },

    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  -- install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = { enabled = false }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
vim.cmd.colorscheme("nord")

-- require("telescope").setup({
--   defaults = {
--     layout_strategy = "horizontal",
--     layout_config = { prompt_position = "top" },
--     sorting_strategy = "ascending",
--     winblend = 0,
--   },
--   extensions = {
--     ["ui-select"] = {
--       require("telescope.themes").get_dropdown({}),
--     },
--   },
-- })
-- -- To get ui-select loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
-- require("telescope").load_extension("ui-select")

require("lspconfig").solargraph.setup({})
require("lspconfig").vtsls.setup({})
require("lspconfig").pyright.setup({})

require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false, -- for neodev users
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- local persistence = require("persistence")
-- if vim.fn.argc() == 1 and vim.v.argv[3] == "." then
--   persistence.load()
-- end
--
require("neo-tree").setup({
  source_selector = {},
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
  },

  config = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    vim.g.neo_tree_auto_open = 0
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    if state and not require("neo-tree.sources.common.preview").is_active() then
      pcall(state.commands.toggle_preview, state)
    end
  end,
  once = true,
})

local neotree_augroup = vim.api.nvim_create_augroup("NeoTreeAutocmds", { clear = true })

-- Create an autocmd to close NeoTree when a file is opened
vim.api.nvim_create_autocmd("BufEnter", {
  group = neotree_augroup,
  pattern = "*",
  callback = function()
    local buf_ft = vim.bo.filetype
    if buf_ft ~= "neo-tree" then
      vim.cmd("Neotree close")
    end
  end,
})

vim.g.minipairs_disable = true

-- vim.keymap.set("n", "<PageUp>", [[<cmd>lua require('custom.tmux_commands').send_page_key_to_tmux('PageUp')<cr>]])
-- vim.keymap.set("n", "<PageDown>", [[<cmd>lua require('custom.tmux_commands').send_page_key_to_tmux('PageDown')<cr>]])
-- Load your custom tmux commands plugin
-- require("custom.tmux_commands")
-- -- Optional: Create keybindings for the plugin functions
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>tp",
--   ':lua require("custom.tmux_commands").set_target_pane()<CR>',
--   { noremap = true, silent = true }
-- )
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>tc",
--   ':lua require("custom.tmux_commands").prompt_and_send_command()<CR>',
--   { noremap = true, silent = true }
-- )
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>tr",
--   ':lua require("custom.tmux_commands").repeat_command()<CR>',
--   { noremap = true, silent = true }
-- )
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>tu",
--   ':lua require("custom.tmux_commands").up_enter()<CR>',
--   { noremap = true, silent = true }
-- )

-- require("echasnovski/mini.indentscope").setup({
--   opts = {
--     draw = { animation = require("mini.indentscope").gen_animation.none() },
--   },
-- })

-- require("bufferline").setup({
--   options = {
--     show_buffer_icons = false, -- Disable icons
--     show_buffer_close_icons = false, -- Disable close icons
--     show_close_icon = false, -- Disable close icon on the right side
--     show_tab_indicators = false, -- Disable tab indicators
--   },
-- })
--
require("conform").setup({
  formatters_by_ft = {
    ruby = {
      "rubocop", -- Add RuboCop as a formatter/linter for Ruby
    },
    format_on_events = false,
  },
})

-- Run the linter/formatter on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rb",
  callback = function()
    require("conform").format({ async = true })
  end,
})

-- require("fzf-lua").setup({
--   winopts = {
--     help = "", -- Disable help line
--   },
-- })
