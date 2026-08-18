local map = vim.keymap.set

map("n", "<Space>za", "za", { desc = "Toggle fold" })
map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>update<cr>", { desc = "Write buffer" })

map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Search text" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffer" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })
