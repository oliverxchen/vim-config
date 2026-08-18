local state_dir = vim.fn.stdpath("state")
local undo_dir = state_dir .. "/undo"
local swap_dir = state_dir .. "/swap"
vim.fn.mkdir(undo_dir, "p")
vim.fn.mkdir(swap_dir, "p")

if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC-52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end

vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.cursorline = true
vim.opt.directory = swap_dir .. "//"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.laststatus = 2
vim.opt.linebreak = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.scrolloff = 4
vim.opt.shiftround = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undodir = undo_dir
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 250
vim.opt.wildmode = { "longest:full", "full" }

vim.diagnostic.config({
  float = { border = "rounded" },
  severity_sort = true,
  underline = true,
  virtual_text = { spacing = 2 },
})
