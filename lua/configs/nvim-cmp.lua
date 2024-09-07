local cmp = require "cmp"
local M = require "nvchad.configs.cmp"

table.insert(M.sources, { name = "crates" })
table.insert(M.sources, { name = "copilot" })

M.mapping = {
  ["<C-p>"] = cmp.mapping.select_prev_item(),
  ["<C-n>"] = cmp.mapping.select_next_item(),
  ["<C-d>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-e>"] = cmp.mapping.close(),
  ["<CR>"] = cmp.mapping.confirm {
    select = true,
  },
}

return M
