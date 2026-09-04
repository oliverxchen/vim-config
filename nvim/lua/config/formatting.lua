local conform = require("conform")
local project_tools = require("config.project_tools")

local function missing_project_tool()
  return "__nvim_project_tool_missing__"
end

local function project_formatter(name, resolver)
  return {
    command = function(_, ctx)
      return resolver(name, ctx.buf) or missing_project_tool()
    end,
    condition = function(_, ctx)
      return resolver(name, ctx.buf) ~= nil
    end,
  }
end

conform.setup({
  formatters_by_ft = {
    go = { "gofmt" },
    javascript = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    javascriptreact = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    json = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    jsonc = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    markdown = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    python = function(bufnr)
      return project_tools.python_tool("ruff", bufnr) and { "ruff_format" } or {}
    end,
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    toml = { "taplo" },
    typescript = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    typescriptreact = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
    yaml = function(bufnr)
      return project_tools.node_tool("prettier", bufnr) and { "prettier" } or {}
    end,
  },
  formatters = {
    prettier = vim.tbl_extend("force", project_formatter("prettier", project_tools.node_tool), {
      prepend_args = {
        "--print-width",
        "80",
        "--prose-wrap",
        "always",
        "--config-precedence",
        "file-override",
      },
    }),
    ruff_format = vim.tbl_extend("force", project_formatter("ruff", project_tools.python_tool), {
      args = {
        "format",
        "--force-exclude",
        "--stdin-filename",
        "$FILENAME",
        "-",
      },
    }),
    taplo = {
      command = "taplo",
      args = {
        "fmt",
        "--stdin-filepath",
        "$FILENAME",
        "--option",
        "indent_tables=true",
        "--option",
        "indent_entries=true",
        "--option",
        "indent_string=  ",
        "-",
      },
    },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat
      or vim.b[bufnr].disable_autoformat
      or not project_tools.repository_root(bufnr)
    then
      return
    end

    return {
      timeout_ms = 1000,
      lsp_format = "fallback",
    }
  end,
})
