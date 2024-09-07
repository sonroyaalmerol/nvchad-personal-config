return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
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
    opts = function ()
      return require "configs.nvimtree"
    end,
  },
  {
    "joerdav/templ.vim",
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function ()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = function ()
      return require "configs.rust-tools"
    end,
    config = function (_, opts)
      require('rust-tools').setup(opts)
    end,
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "saecki/crates.nvim",
    dependencies = "hrsh7th/nvim-cmp",
    ft = {"rust", "toml"},
    config = function (_, opts)
      local crates = require("crates")
      crates.setup(opts)
      crates.show()
    end,
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
    dependencies = {
      "zbirenbaum/copilot-cmp",
      config = function ()
        if vim.bo.filetype == "rust" then return end
        require("copilot_cmp").setup()
      end
    },
    opts = function ()
      return require "configs.nvim-cmp"
    end
  },
  {
    "rcarriga/nvim-notify"
  },
  {
    "dmmulroy/tsc.nvim",
    config = function ()
      require("tsc").setup()
    end
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function ()
      require "configs.nvim-jdtls"
    end
  },
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
}
