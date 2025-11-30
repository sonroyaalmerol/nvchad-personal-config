return {
  {
    "nvchad/base46",
    lazy = false,
    priority = 1000,
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "nvchad/ui",
    lazy = false,
    priority = 999,
    config = function()
      require "nvchad"
      require("material-you.colors").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufRead",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = function()
      return require "configs.nvimtree"
    end,
  },
  {
    "mfussenegger/nvim-dap",
  },
  --  {
  --    "zbirenbaum/copilot.lua",
  --    event = function ()
  --      if vim.bo.filetype == "rust" then
  --        return {}
  --      end
  --
  --      return {"InsertEnter"}
  --    end,
  --    opts = function ()
  --      local M = {}
  --      M.copilot = {
  --        suggestion = {
  --          auto_trigger = true,
  --        },
  --      }
  --
  --      return M
  --    end
  --  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      return require "configs.nvim-cmp"
    end,
  },
  {
    "rcarriga/nvim-notify",
  },
  {
    "dmmulroy/tsc.nvim",
    config = function()
      require("tsc").setup()
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
}
