local lint = require("lint")

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
    lint.try_lint()
  end,
})
