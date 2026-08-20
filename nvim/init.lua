if vim.fn.has("nvim-0.12.0") == 0 then
  error("This configuration requires Neovim 0.12.0 or newer")
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.api.nvim_create_user_command("Term", function()
  vim.cmd("botright 10split | terminal")
end, { desc = "Open terminal in a bottom split" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_commit = "85c7ff3711b730b4030d03144f6db6375044ae82"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--no-checkout",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not clone lazy.nvim")
  end
end

local current_lazy_commit = vim.fn.system({ "git", "-C", lazypath, "rev-parse", "HEAD" })
if vim.v.shell_error ~= 0 then
  error("Could not read the lazy.nvim checkout")
end

if vim.trim(current_lazy_commit) ~= lazy_commit then
  vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", lazy_commit })
  if vim.v.shell_error ~= 0 then
    error("Could not check out the pinned lazy.nvim commit")
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  rocks = { enabled = false },
  checker = { enabled = false },
  change_detection = { enabled = false, notify = false },
  install = { colorscheme = { "onedark_dark" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
