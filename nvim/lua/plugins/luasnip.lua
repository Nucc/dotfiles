-- return {
--   -- Use <tab> for completion and snippets (supertab)
--   -- first: disable default <tab> and <s-tab> behavior in LuaSnip
--   {
--     "L3MON4D3/LuaSnip",
--     keys = function()
--       return {}
--     end,
--   },
--   -- then: setup supertab in cmp
--   {
--     "hrsh7th/nvim-cmp",
--     dependencies = {
--       "hrsh7th/cmp-emoji",
--     },
--     ---@param opts cmp.ConfigSchema
--     opts = function(_, opts)
--       local has_words_before = function()
--         unpack = unpack or table.unpack
--         local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--         return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
--       end
--
--       local luasnip = require("luasnip")
--       local cmp = require("cmp")
--
--       opts.mapping = vim.tbl_extend("force", opts.mapping, {
--         ["<CR>"] = cmp.config.disable,
--         ["<Tab>"] = cmp.mapping.confirm({ select = true }),
--         ["<C-j>"] = cmp.mapping(function(fallback) end, { "i", "s" }),
--       })
--     end,
--   },
-- -- }
--
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Predefined snippets for popular languages
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load() -- Load VSCode-style snippets
      require("luasnip").filetype_extend("ruby", { "rails" })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip", -- Snippet completion for LuaSnip
    },
    -- config = function()
    --   local cmp = require("cmp")
    --   local luasnip = require("luasnip")
    --
    --   cmp.setup({
    --     snippet = {
    --       expand = function(args)
    --         luasnip.lsp_expand(args.body)
    --       end,
    --     },
    --     mapping = {
    --       ["<Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_next_item()
    --         elseif luasnip.expand_or_jumpable() then
    --           luasnip.expand_or_jump()
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       ["<S-Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_prev_item()
    --         elseif luasnip.jumpable(-1) then
    --           luasnip.jump(-1)
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --     },
    --     sources = {
    --       { name = "nvim_lsp" },
    --       { name = "luasnip" },
    --     },
    --   })
    -- end,
  },
}
