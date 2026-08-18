return {
  {
    "neovim/nvim-lspconfig",
    version = "v2.11.0",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("config.lsp")
    end,
  },
  {
    "stevearc/conform.nvim",
    version = "v9.1.0",
    event = { "BufReadPre", "BufNewFile", "BufWritePre" },
    config = function()
      require("config.formatting")
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.lint")
    end,
  },
}
