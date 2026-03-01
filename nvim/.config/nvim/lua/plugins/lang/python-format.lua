return {
  -- Formatter: black + isort
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "isort", "black" },
      },
    },
  },

  -- Debugger: debugpy
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      keys = {
        { "<leader>dPt", function() require("dap-python").test_method() end, desc = "Debug Method" },
        { "<leader>dPc", function() require("dap-python").test_class() end, desc = "Debug Class" },
      },
      config = function()
        require("dap-python").setup("python")
      end,
    },
  },

  -- Ensure mason installs these tools
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "black",
        "isort",
        "debugpy",
      },
    },
  },
}
