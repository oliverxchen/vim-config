local cursorline_group = vim.api.nvim_create_augroup("user_cursorline", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

vim.cmd([[command! -nargs=* W execute 'write' <q-args>]])
vim.cmd([[command! -nargs=* Wq execute 'wq' <q-args>]])
