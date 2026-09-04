local lint = require("lint")
local project_tools = require("config.project_tools")

local ruff = vim.deepcopy(require("lint.linters.ruff"))
ruff.cmd = function()
  return project_tools.python_tool("ruff", vim.api.nvim_get_current_buf())
    or "__nvim_project_tool_missing__"
end
lint.linters.ruff = ruff

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  python = { "ruff" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
}

local lint_group = vim.api.nvim_create_augroup("user_lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  group = lint_group,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = project_tools.repository_root(bufnr)
    if not root then
      return
    end
    if vim.bo[bufnr].filetype == "python" and not project_tools.python_tool("ruff", bufnr) then
      return
    end

    lint.try_lint(nil, { cwd = root })
  end,
})
