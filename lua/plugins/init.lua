return {
  {
    "nvchad/ui",
    lazy = false,
    config = function()
      require "nvchad"
      local function inject_material_colors()
        package.loaded["material-you.colors"] = nil
        local success, my_colors = pcall(require, "material-you.colors")

        if not success then
          return
        end

        local highlights = my_colors.get_highlights()
        if not highlights or next(highlights) == nil then
          print "MaterialYou: No highlights generated"
          return
        end

        local nvconfig = require "nvconfig"

        nvconfig.base46.hl_override = vim.tbl_deep_extend("force", nvconfig.base46.hl_override or {}, highlights)

        require("base46").load_all_highlights()
      end

      inject_material_colors()

      local cfg = vim.fn.stdpath "config"
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = cfg .. "/*",
        callback = function()
          vim.defer_fn(inject_material_colors, 50)
        end,
      })
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
