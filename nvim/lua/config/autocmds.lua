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

local neo_tree_group = vim.api.nvim_create_augroup("user_neo_tree", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = neo_tree_group,
  nested = true,
  callback = function()
    if vim.fn.argc() ~= 0 or vim.api.nvim_buf_get_name(0) ~= "" then
      return
    end

    vim.schedule(function()
      if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
        vim.cmd("Neotree filesystem show left")
      end
    end)
  end,
})

local neo_tree_quitting = false

local function is_neo_tree_filetype(filetype)
  return filetype == "neo-tree" or filetype == "neo-tree-popup" or filetype == "neo-tree-preview"
end

local function quit_when_only_neo_tree_remains()
  if neo_tree_quitting then
    return
  end

  vim.schedule(function()
    if neo_tree_quitting or vim.v.exiting == 1 then
      return
    end

    local has_neo_tree_window = false
    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        local bufnr = vim.api.nvim_win_get_buf(win)
        if is_neo_tree_filetype(vim.bo[bufnr].filetype) then
          has_neo_tree_window = true
        else
          return
        end
      end
    end

    if not has_neo_tree_window then
      return
    end

    neo_tree_quitting = true
    if not pcall(vim.cmd, "quitall") then
      neo_tree_quitting = false
    end
  end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinClosed" }, {
  group = neo_tree_group,
  callback = quit_when_only_neo_tree_remains,
})

vim.cmd([[command! -nargs=* W execute 'write' <q-args>]])
vim.cmd([[command! -nargs=* Wq execute 'wq' <q-args>]])
