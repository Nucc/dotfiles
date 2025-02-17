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

        -- api_host_cmd = 'echo -n ""',
        -- api_key_cmd = "pass azure-openai-key",
        -- api_type_cmd = "echo azure",
        -- azure_api_base_cmd = "echo https://chatgpt.zende.sk",
        -- azure_api_engine_cmd = "echo chat",
        -- azure_api_version_cmd = "echo 2023-05-15",
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
