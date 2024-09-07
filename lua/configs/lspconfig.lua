-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

vim.filetype.add({ extension = { templ = "templ" } })

local servers = {
  "html",
  "cssls",
  "clangd",
  "ts_ls",
  "pyright",
  "tailwindcss",
  "graphql",
  "gopls",
  "omnisharp",
  "templ",
  "htmx",
}

for _, lsp in ipairs(servers) do
  local custom_capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  }
  local merged_capabilities = vim.tbl_deep_extend("force", capabilities, custom_capabilities)

  if lsp == "omnisharp" then
    local pid = vim.fn.getpid()
    local omnisharp_bin = "/usr/local/bin/omnisharp-roslyn/OmniSharp"
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
      cmd = {
        omnisharp_bin, "--languageserver", "--hostPID", tostring(pid)
      }
    }
  elseif lsp == "html" or lsp == "htmx" then
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "html", "templ" },
    })
  elseif lsp == "tailwindcss" then
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "templ", "astro", "javascript", "typescript", "react" },
      init_options = { userLanguages = { templ = "html" } },
    })
  else
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = merged_capabilities,
      flags = {
        debounce_text_changes = 150,
      }
    })
  end
end

local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimport()
  end,
  group = format_sync_grp,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" },
  callback = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cmd = "templ fmt " .. vim.fn.shellescape(filename)

    vim.fn.jobstart(cmd, {
      on_exit = function()
        -- Reload the buffer only if it's still the current buffer
        if vim.api.nvim_get_current_buf() == bufnr then
          vim.cmd('e!')
        end
      end,
    })
  end
})

