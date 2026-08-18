local function on_attach(client, bufnr)
  local function bufmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
  bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  bufmap("n", "gr", vim.lsp.buf.references, "Find references")
  bufmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  bufmap("n", "K", vim.lsp.buf.hover, "Show hover information")
  bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

  if client.server_capabilities.documentFormattingProvider then
    client.server_capabilities.documentFormattingProvider = false
  end
  if client.server_capabilities.documentRangeFormattingProvider then
    client.server_capabilities.documentRangeFormattingProvider = false
  end
end

local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  ty = {},
  ts_ls = {},
  gopls = {},
  taplo = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { "taplo.toml", "pyproject.toml", "Cargo.toml", ".git" },
  },
}

for name, config in pairs(servers) do
  config.capabilities = capabilities
  config.on_attach = on_attach
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
