local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    go = { "gofmt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    python = { "ruff_format" },
    sh = { "shfmt" },
    terraform = { "prettier" },
    toml = { "taplo" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    yaml = { "prettier" },
  },
  formatters = {
    taplo = {
      command = "taplo",
      args = { "fmt", "--stdin-filepath", "$FILENAME", "-" },
    },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end

    return {
      timeout_ms = 1000,
      lsp_format = "fallback",
    }
  end,
})
