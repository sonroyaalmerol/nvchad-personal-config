local M = {}

-- Get quickshell config
local function get_quickshell_config()
  local xdg_config = os.getenv "XDG_CONFIG_HOME" or (os.getenv "HOME" .. "/.config")
  local config_file = xdg_config .. "/illogical-impulse/config.json"

  if vim.fn.filereadable(config_file) ~= 1 then
    return nil
  end

  local ok, json_content = pcall(vim.fn.readfile, config_file)
  if not ok or not json_content then
    return nil
  end

  local json_str = table.concat(json_content, "\n")
  local ok_decode, config = pcall(vim.json.decode, json_str)
  if not ok_decode or not config then
    return nil
  end

  return config
end

-- Get wallpaper and theme options from quickshell
local function get_quickshell_opts()
  local config = get_quickshell_config()
  if not config then
    return nil
  end

  local opts = {}

  -- Get wallpaper
  if config.background and config.background.wallpaperPath then
    opts.wallpaper = vim.fn.expand(config.background.wallpaperPath)
  end

  -- Get theme settings
  if config.appearance then
    if config.appearance.palette and config.appearance.palette.type then
      opts.scheme = config.appearance.palette.type
    end

    if config.appearance.wallpaperTheming and config.appearance.wallpaperTheming.terminalGenerationProps then
      local tgp = config.appearance.wallpaperTheming.terminalGenerationProps
      opts.harmony = tgp.harmony or 0.6
      opts.harmonize_threshold = tgp.harmonizeThreshold or 100
      opts.term_fg_boost = tgp.termFgBoost or 0.35
    end
  end

  return opts
end

-- Generate Material You colors from Python script
local function generate_material_colors()
  local xdg_config = os.getenv "XDG_CONFIG_HOME" or (os.getenv "HOME" .. "/.config")
  local script_path = xdg_config .. "/quickshell/ii/scripts/colors/generate_colors_material.py"
  local termscheme = xdg_config .. "/quickshell/ii/scripts/terminal/scheme-base.json"

  if vim.fn.filereadable(script_path) ~= 1 then
    return nil
  end

  local opts = get_quickshell_opts()
  if not opts or not opts.wallpaper then
    return nil
  end

  local cmd = {
    script_path,
    "--path",
    opts.wallpaper,
    "--mode",
    vim.o.background,
    "--scheme",
    opts.scheme or "vibrant",
    "--harmony",
    tostring(opts.harmony),
    "--harmonize_threshold",
    tostring(opts.harmonize_threshold),
    "--term_fg_boost",
    tostring(opts.term_fg_boost),
    "--blend_bg_fg",
  }

  if vim.fn.filereadable(termscheme) == 1 then
    table.insert(cmd, "--termscheme")
    table.insert(cmd, termscheme)
  end

  local output = vim.fn.system(table.concat(cmd, " "))
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Parse colors
  local colors = {}
  for line in output:gmatch "[^\r\n]+" do
    local key, value = line:match "%$([%w_]+):%s*([^;]+)"
    if key and value then
      colors[key] = value:gsub("%s+", "")
    end
  end

  return colors
end

function M.get_highlights()
  -- Generate Material You colors
  local material_colors = generate_material_colors()
  if not material_colors then
    vim.notify("Failed to generate Material You colors from quickshell config", vim.log.levels.WARN)
    -- Return an empty table instead of nil to prevent type errors in consumer functions
    return {}
  end

  local c = material_colors

  c.surface = "NONE"
  c.surfaceDim = "NONE"
  -- Keep container backgrounds slightly visible for contrast
  c.surfaceContainer = "NONE"

  -- Update nvconfig with highlight overrides
  local nvconfig = require "nvconfig"
  nvconfig.base46 = nvconfig.base46 or {}

  -- Set a base theme (required for base46 to work)
  nvconfig.base46.theme = nvconfig.base46.theme or "onedark"

  local statusline_bg = c.surface
  local lightbg = c.surfaceContainer

  -- Override all highlights with Material You colors
  ---@type Base46HLGroupsList
  return {
    -- Editor basics
    Normal = { fg = c.onSurface, bg = c.surface },
    NormalFloat = { fg = c.onSurface, bg = c.surfaceContainer },

    -- UI Elements
    StatusLine = { fg = c.onSurface, bg = c.surfaceContainer },
    Tabline = { fg = c.onSurfaceVariant, bg = c.surfaceContainer }, -- FIXED: TabLine -> Tabline
    WinSeparator = { fg = c.outlineVariant },

    -- Cursor and lines
    Cursor = { fg = c.surface, bg = c.onSurface },
    CursorLine = { bg = c.surfaceContainerHighest },
    CursorLineNr = { fg = c.primary, bg = c.surfaceContainerHighest },
    LineNr = { fg = c.onSurfaceVariant },
    SignColumn = { fg = c.onSurfaceVariant, bg = c.surface },
    ColorColumn = { bg = c.surfaceContainerHigh },

    -- Popups and menus
    Pmenu = { fg = c.onSurface, bg = c.surfaceContainer },
    PmenuSel = { fg = c.onPrimaryContainer, bg = c.primaryContainer },
    PmenuSbar = { bg = c.surfaceContainerHigh },
    PmenuThumb = { bg = c.onSurfaceVariant },

    -- Selection and search
    Visual = { bg = c.secondaryContainer },
    VisualNOS = { bg = c.secondaryContainer },
    Search = { fg = c.onTertiaryContainer, bg = c.tertiaryContainer },
    IncSearch = { fg = c.onTertiary, bg = c.tertiary },
    -- CurSearch = { fg = c.onTertiary, bg = c.tertiary }, -- NOT IN TYPE DEF

    -- Syntax
    Comment = { fg = c.onSurfaceVariant, italic = true },
    Constant = { fg = c.tertiary },
    String = { fg = c.tertiary },
    Character = { fg = c.tertiary },
    Number = { fg = c.tertiary },
    Boolean = { fg = c.tertiary },
    Float = { fg = c.tertiary },
    Identifier = { fg = c.onSurface },
    Function = { fg = c.primary },
    Statement = { fg = c.secondary },
    Conditional = { fg = c.secondary },
    Repeat = { fg = c.secondary },
    Label = { fg = c.secondary },
    Operator = { fg = c.onSurface },
    Keyword = { fg = c.secondary },
    Exception = { fg = c.error },
    PreProc = { fg = c.primary },
    Include = { fg = c.primary },
    Define = { fg = c.primary },
    Macro = { fg = c.primary },
    Type = { fg = c.primary },
    StorageClass = { fg = c.secondary },
    Structure = { fg = c.primary },
    Typedef = { fg = c.primary },
    Special = { fg = c.tertiary },

    -- Diagnostics
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.tertiary },
    DiagnosticInfo = { fg = c.primary },
    DiagnosticHint = { fg = c.onSurfaceVariant },

    -- Git/Diff
    DiffAdd = { fg = c.success, bg = c.successContainer },
    DiffChange = { fg = c.tertiary, bg = c.tertiaryContainer },
    DiffDelete = { fg = c.error, bg = c.errorContainer },
    DiffText = { fg = c.onTertiaryContainer, bg = c.tertiaryContainer },

    -- NvimTree
    NvimTreeNormal = { fg = c.onSurface, bg = c.surface },
    NvimTreeNormalNC = { fg = c.onSurface, bg = c.surface },
    NvimTreeWinSeparator = { fg = c.outlineVariant, bg = c.surface },
    NvimTreeRootFolder = { fg = c.primary, bold = true },
    NvimTreeFolderName = { fg = c.primary },
    NvimTreeFolderIcon = { fg = c.primary },
    NvimTreeOpenedFolderName = { fg = c.primary, bold = true },
    NvimTreeEmptyFolderName = { fg = c.onSurfaceVariant },
    NvimTreeIndentMarker = { fg = c.outline },
    NvimTreeGitDirty = { fg = c.tertiary },
    NvimTreeGitNew = { fg = c.success or c.tertiary },
    NvimTreeGitDeleted = { fg = c.error },
    NvimTreeSpecialFile = { fg = c.tertiary },
    NvimTreeCursorLine = { bg = c.surfaceContainerHighest },

    -- Telescope
    TelescopeNormal = { fg = c.onSurface, bg = c.surface },
    TelescopeBorder = { fg = c.outline, bg = c.surface },
    TelescopePromptNormal = { fg = c.onSurface, bg = c.surfaceContainer },
    TelescopePromptBorder = { fg = c.outline, bg = c.surfaceContainer },
    TelescopePromptPrefix = { fg = c.primary, bg = c.surfaceContainer },
    TelescopeSelection = { fg = c.onSurface, bg = c.surfaceContainerHighest },
    TelescopeMatching = { fg = c.primary, bold = true },

    -- Treesitter
    ["@variable"] = { fg = c.onSurface },
    ["@variable.builtin"] = { fg = c.secondary },
    ["@constant"] = { fg = c.tertiary },
    ["@constant.builtin"] = { fg = c.tertiary },
    ["@string"] = { fg = c.tertiary },
    ["@number"] = { fg = c.tertiary },
    ["@boolean"] = { fg = c.tertiary },
    ["@function"] = { fg = c.primary },
    ["@function.builtin"] = { fg = c.primary },
    ["@keyword"] = { fg = c.secondary },
    ["@keyword.function"] = { fg = c.secondary },
    ["@type"] = { fg = c.primary },
    ["@operator"] = { fg = c.onSurface },
    ["@punctuation.delimiter"] = { fg = c.onSurfaceVariant },
    ["@punctuation.bracket"] = { fg = c.onSurfaceVariant },
    ["@comment"] = { fg = c.onSurfaceVariant, italic = true },

    -- LSP
    ["@lsp.type.class"] = { fg = c.primary },
    ["@lsp.type.function"] = { fg = c.primary },
    ["@lsp.type.method"] = { fg = c.primary },
    ["@lsp.type.variable"] = { fg = c.onSurface },
    ["@lsp.type.parameter"] = { fg = c.onSurface },

    -- Tabufline (NvChad's buffer/tab line)
    TbFill = { bg = c.surface },
    TbBufOn = { fg = c.onSurface, bg = c.surfaceContainerHighest },
    TbBufOff = { fg = c.onSurfaceVariant, bg = c.surface },
    TbBufOnModified = { fg = c.tertiary, bg = c.surfaceContainerHighest },
    TbBufOffModified = { fg = c.tertiary, bg = c.surface },
    TbBufOnClose = { fg = c.error, bg = c.surfaceContainerHighest },
    TbBufOffClose = { fg = c.error, bg = c.surface },
    TbTabOn = { fg = c.onPrimaryContainer, bg = c.primaryContainer },
    TbTabOff = { fg = c.onSurfaceVariant, bg = c.surface },
    TbTabCloseBtn = { fg = c.error, bg = c.surface },
    TbThemeToggleBtn = { fg = c.primary, bg = c.surface },

    -- Statusline - Base
    St_NormalMode = { fg = c.onPrimary, bg = c.primary },
    St_InsertMode = { fg = c.onTertiary, bg = c.tertiary },
    St_VisualMode = { fg = c.onSecondary, bg = c.secondary },
    St_ReplaceMode = { fg = c.onError, bg = c.error },
    St_CommandMode = { fg = c.onTertiary, bg = c.tertiary },
    St_TerminalMode = { fg = c.onPrimary, bg = c.primary },
    St_NTerminalMode = { fg = c.onPrimary, bg = c.primary },
    St_ConfirmMode = { fg = c.onTertiary, bg = c.tertiary },
    St_SelectMode = { fg = c.onSecondary, bg = c.secondary },

    -- Statusline - Separators for each mode
    St_NormalModeSep = { fg = c.primary, bg = c.surfaceContainer },
    St_InsertModeSep = { fg = c.tertiary, bg = c.surfaceContainer },
    St_VisualModeSep = { fg = c.secondary, bg = c.surfaceContainer },
    St_ReplaceModeSep = { fg = c.error, bg = c.surfaceContainer },
    St_CommandModeSep = { fg = c.tertiary, bg = c.surfaceContainer },
    St_TerminalModeSep = { fg = c.primary, bg = c.surfaceContainer },
    St_NTerminalModeSep = { fg = c.primary, bg = c.surfaceContainer },
    St_ConfirmModeSep = { fg = c.tertiary, bg = c.surfaceContainer },
    St_SelectModeSep = { fg = c.secondary, bg = c.surfaceContainer },

    -- Statusline - Main sections
    St_EmptySpace = { fg = c.onSurfaceVariant, bg = lightbg },
    St_file = { bg = lightbg, fg = c.onSurface },
    St_file_sep = { bg = statusline_bg, fg = lightbg },

    -- CWD section (left side with icon)
    St_cwd_icon = { fg = c.surface, bg = c.primary },
    St_cwd_text = { fg = c.onSurface, bg = lightbg },
    St_cwd_sep = { fg = c.primary, bg = statusline_bg },

    -- Position section (right side)
    St_pos_sep = { fg = c.tertiary, bg = lightbg },
    St_pos_icon = { fg = c.onTertiary, bg = c.tertiary },
    St_pos_text = { fg = c.tertiary, bg = lightbg },

    -- Git icons
    St_gitIcons = { fg = c.onSurfaceVariant, bg = statusline_bg, bold = true },

    -- LSP status
    St_Lsp = { fg = c.primary, bg = statusline_bg },
    St_LspMsg = { fg = c.tertiary, bg = statusline_bg },
    -- St_LspStatus = { fg = c.primary, bg = statusline_bg }, -- NOT IN TYPE DEF

    -- LSP diagnostics
    St_lspError = { fg = c.error, bg = statusline_bg },
    St_lspWarning = { fg = c.tertiary, bg = statusline_bg },
    St_LspHints = { fg = c.secondary, bg = statusline_bg },
    St_LspInfo = { fg = c.primary, bg = statusline_bg },
  }
end

function M.setup_terminal()
  local c = generate_material_colors()
  if c and c.term0 then
    for i = 0, 15 do
      vim.g["terminal_color_" .. i] = c["term" .. i]
    end
  end
end

return M
