return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      ensure_installed = {
        "bash",
        "go",
        "javascript",
        "json",
        "markdown",
        "python",
        "query",
        "sql",
        "terraform",
        "toml",
        "typescript",
        "vim",
        "yaml",
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "v0.2.1",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "%.git/", "%.pyc$", "__pycache__/" },
      },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" } },
    opts = {
      view_options = { show_hidden = true },
    },
  },
  {
    "saghen/blink.cmp",
    version = "v1.10.2",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      completion = {
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
    },
  },
  {
    "nvim-mini/mini.nvim",
    version = "v0.18.0",
    event = "VeryLazy",
    config = function()
      require("mini.comment").setup()
    end,
  },
  {
    "chrisbra/csv.vim",
    event = { "BufReadPost *.csv", "BufNewFile *.csv" },
  },
}
