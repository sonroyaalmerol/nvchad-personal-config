-- Import required modules
local nvchad_config = require "nvchad.configs.lspconfig"

-- Load default configurations
nvchad_config.defaults()

-- Get default handlers
local on_attach = nvchad_config.on_attach
local capabilities = nvchad_config.capabilities

-- Define LSP servers to configure
local servers = {
  "buf_ls",
  "html",
  "cssls",
  "clangd",
  "ts_ls",
  "basedpyright",
  "gopls",
  "zls",
  "hyprls",
  "nil_ls",
  "docker_compose_language_service",
  "dockerls",
  "rust_analyzer",
}

-- Enhanced capabilities for file watching
local enhanced_capabilities = {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  },
}

-- Merge default and enhanced capabilities
local merged_capabilities = vim.tbl_deep_extend("force", capabilities, enhanced_capabilities)

-- Configure each LSP server
for _, lsp in ipairs(servers) do
  local config = {
    on_attach = on_attach,
    capabilities = merged_capabilities,
    flags = {
      debounce_text_changes = 150,
    },
  }

  -- Special configuration for HTML
  if lsp == "html" then
    config.filetypes = { "html" }
    config.capabilities = capabilities -- Use default capabilities
  end

  -- Special configuration for buf_ls
  if lsp == "buf_ls" then
    config.cmd = { "buf", "beta", "lsp" }
  end

  -- Setup the LSP
  vim.lsp.config(lsp, config)
  vim.lsp.enable(lsp)
end

-- Auto-formatting for Go files
local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require("go.format").goimport()
  end,
  group = format_sync_grp,
})

-- Configure Hyprland LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    vim.notify(string.format("Starting hyprls for %s", vim.inspect(event)), vim.log.levels.INFO)
    vim.lsp.start {
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    }
  end,
})
