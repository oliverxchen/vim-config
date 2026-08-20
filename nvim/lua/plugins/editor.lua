local treesitter_languages = {
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
}

local treesitter_filetypes = {
  "bash",
  "go",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "markdown",
  "python",
  "query",
  "sql",
  "terraform",
  "toml",
  "typescript",
  "typescriptreact",
  "vim",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup()
      -- Keep first-run setup from exiting before the asynchronous parser builds finish.
      treesitter.install(treesitter_languages):wait(300000)

      vim.treesitter.language.register("javascript", { "javascriptreact" })
      vim.treesitter.language.register("json", { "jsonc" })
      vim.treesitter.language.register("typescript", { "typescriptreact" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = treesitter_filetypes,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "v0.2.1",
    cmd = { "Telescope", "Fg", "Fb" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "%.git/", "%.pyc$", "__pycache__/" },
        file_sorter = function(sorter_opts)
          return require("telescope.sorters").get_fuzzy_file(sorter_opts)
        end,
        path_display = { "filename_first" },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      vim.api.nvim_create_user_command("Fg", function()
        require("telescope.builtin").live_grep()
      end, { desc = "Search text" })
      vim.api.nvim_create_user_command("Fb", function()
        require("telescope.builtin").buffers()
      end, { desc = "Find buffer" })
    end,
  },
  {
    "stevearc/oil.nvim",
    cmd = { "Oil", "Fe" },
    opts = {
      view_options = { show_hidden = true },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      vim.api.nvim_create_user_command("Fe", function()
        require("oil").open()
      end, { desc = "File explorer" })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree filesystem toggle left<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>Neotree filesystem reveal left<cr>", desc = "Reveal file in tree" },
    },
    opts = {
      close_if_last_window = false,
      default_component_configs = {
        name = {
          highlight_opened_files = true,
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        -- Oil remains responsible for directory buffers such as `:edit .`.
        hijack_netrw_behavior = "disabled",
      },
      window = {
        position = "left",
        width = 30,
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
      vim.api.nvim_create_user_command("E", "Neotree filesystem toggle left", {
        desc = "Toggle file tree",
      })
      vim.api.nvim_create_user_command("Ee", "Neotree filesystem reveal left", {
        desc = "Reveal current file in tree",
      })
    end,
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
