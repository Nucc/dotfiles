return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        show_buffer_icons = false, -- Disable icons
        show_buffer_close_icons = false, -- Disable close icons
        show_close_icon = false, -- Disable close icon on the right side
        show_tab_indicators = false, -- Disable tab indicators
      },
    })
  end,
}
