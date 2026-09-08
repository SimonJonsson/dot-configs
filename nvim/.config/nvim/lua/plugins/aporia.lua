return {
  {
    dir = "~/Repos/aporia.nvim",
    cmd = "Aporia",
    keys = {
      { "<leader>aq", desc = "Aporia: question check (Forming)", mode = { "n", "v" } },
      { "<leader>ah", desc = "Aporia: hint ladder (Dislodging)", mode = { "n", "v" } },
      { "<leader>ar", desc = "Aporia: reframe (Assumption)", mode = { "n", "v" } },
      { "<leader>as", desc = "Aporia: step audit (Location)", mode = { "n", "v" } },
      { "<leader>ac", desc = "Aporia: root-cause challenge (Achievement)", mode = { "n", "v" } },
      { "<leader>al", desc = "Aporia: log what I learned (Progression)", mode = { "n", "v" } },
      { "<leader>at", desc = "Aporia: toggle chat", mode = { "n", "v", "i" } },
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
        },
      },
    },
  },
}
