local map = vim.keymap.set

vim.api.nvim_create_user_command("Z", function()
  vim.cmd("normal! za")
end, { desc = "Toggle fold" })

map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>update<cr>", { desc = "Write buffer" })

map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })
