require "nvchad.mappings"

-- add yours here
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to declaration" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "Go to references" })
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "Signature help" })
map("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", { desc = "Add workspace folder" })
map("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", { desc = "Remove workspace folder" })
map("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", { desc = "List workspace folders" })
map("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Type definition" })
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code action" })
map("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", { desc = "Show line diagnostics" })
map("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", { desc = "Set loclist" })
map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", { desc = "Previous diagnostic" })
map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", { desc = "Next diagnostic" })
map("n", "<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", { desc = "Format" })
map("n", "<leader>fe", "<cmd>lua vim.lsp.buf.formatting_sync(nil, 1000)<CR>", { desc = "Format sync" })
map("n", "<leader>fs", "<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>", { desc = "Format seq sync" })


local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
