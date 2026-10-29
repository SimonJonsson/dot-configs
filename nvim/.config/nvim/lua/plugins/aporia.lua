return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "aporia assist", mode = { "n", "v" } },
        { "<leader>t", group = "aporia teach", mode = { "n", "v" } },
      },
    },
  },
  {
    dir = "~/Repos/aporia.nvim",
    cmd = "Aporia",
    keys = {
      { "<leader>tq", desc = "Aporia: question check (Forming)", mode = { "n", "v" } },
      { "<leader>th", desc = "Aporia: hint ladder (Dislodging)", mode = { "n", "v" } },
      { "<leader>tr", desc = "Aporia: reframe (Assumption)", mode = { "n", "v" } },
      { "<leader>ts", desc = "Aporia: step audit (Location)", mode = { "n", "v" } },
      { "<leader>tc", desc = "Aporia: root-cause challenge (Achievement)", mode = { "n", "v" } },
      { "<leader>tl", desc = "Aporia: log what I learned (Progression)", mode = { "n", "v" } },
      { "<leader>tt", desc = "Aporia: toggle chat (teach)", mode = { "n", "v" } },
      { "<leader>at", desc = "Aporia: toggle chat (assist)", mode = { "n", "v", "i" } },
      { "<leader>aa", desc = "Aporia: stage selection", mode = { "n", "v" } },
      { "<leader>ab", desc = "Aporia: stage buffer", mode = { "n", "v" } },
    },
    opts = {
      provider = "baseten",
      providers = {
        baseten = {
          base_url = "https://inference.baseten.co/v1",
          model = "zai-org/GLM-5.3-Fast",
          api_key_env = "BASETEN_API_KEY",
          api_key_cmd = "cat ~/baseten_apikey",
        },
      },
    },
  },
}
