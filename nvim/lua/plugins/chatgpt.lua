return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local config = {
        openai_params = {
          model = "gpt-4o-2024-11-20",
          frequency_penalty = 0,
          presence_penalty = 0,
          max_tokens = 4095,
          temperature = 0.5,
          top_p = 0.1,
          n = 1,
        },
        keymaps = {
          toggle_session = "<C-i>", -- Change this to your desired shortcut
        },
      }
      require("chatgpt").setup(config)
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
