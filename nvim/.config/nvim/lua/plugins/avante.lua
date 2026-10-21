-- avante itself comes from the lazyvim.plugins.extras.ai.avante extra; this only swaps the provider
return {
  "yetone/avante.nvim",
  opts = {
    provider = "baseten",
    providers = {
      -- OpenAI-compatible endpoint; key lives in ~/.secrets.fish (BASETEN_API_KEY)
      baseten = {
        __inherited_from = "openai",
        endpoint = "https://inference.baseten.co/v1",
        api_key_name = "BASETEN_API_KEY",
        model = "zai-org/GLM-5.3-Flash",
        timeout = 30000,
        extra_request_body = { temperature = 0.2, max_tokens = 16384 },
      },
    },
  },
}
