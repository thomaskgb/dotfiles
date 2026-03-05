-- Shargeek palette applied to tokyonight-night as base
-- Signal Yellow #E8B830  Amber #D4A017  Ice Blue #B8D8E8
-- OLED Green #3AE070  OLED Blue #4A9EF5  OLED Red #E84040
-- Gunmetal #3A3D42  Deep Black #111113  Surface Dark #1C1D1F
-- Surface Mid #2E3034  Text Primary #E8E8EA  Text Muted #8A8D93

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = false,
      on_colors = function(c)
        c.bg        = "#111113"  -- deep-black
        c.bg_dark   = "#0D0D0F"
        c.bg_float  = "#1C1D1F"  -- surface-dark
        c.bg_popup  = "#1C1D1F"
        c.bg_sidebar = "#1C1D1F"
        c.bg_highlight = "#2E3034"  -- surface-mid
        c.bg_visual = "#2E3034"
        c.border    = "#3A3D42"  -- gunmetal
        c.fg        = "#E8E8EA"  -- text-primary
        c.fg_dark   = "#8A8D93"  -- text-muted
        c.fg_gutter = "#8A8D93"
        c.comment   = "#8A8D93"
        c.yellow    = "#E8B830"  -- signal-yellow
        c.orange    = "#D4A017"  -- amber-accent
        c.green     = "#3AE070"  -- oled-green
        c.blue      = "#4A9EF5"  -- oled-blue
        c.cyan      = "#B8D8E8"  -- ice-blue
        c.red       = "#E84040"  -- oled-red
        c.magenta   = "#A8ADB3"  -- chrome-silver
      end,
      on_highlights = function(hl, c)
        -- Editor
        hl.CursorLine      = { bg = c.bg_highlight }
        hl.ColorColumn     = { bg = c.bg_highlight }
        hl.WinSeparator    = { fg = c.border }
        hl.VertSplit       = { fg = c.border }
        hl.LineNr          = { fg = "#8A8D93" }
        hl.CursorLineNr    = { fg = "#E8B830", bold = true }
        hl.SignColumn      = { bg = c.bg }

        -- Syntax: key tokens → Shargeek roles
        hl["@keyword"]         = { fg = "#E8B830", bold = true }  -- signal-yellow
        hl["@keyword.return"]  = { fg = "#E8B830", bold = true }
        hl["@keyword.function"] = { fg = "#E8B830", bold = true }
        hl.Keyword             = { fg = "#E8B830", bold = true }
        hl.Statement           = { fg = "#E8B830" }
        hl["@function"]        = { fg = "#B8D8E8" }               -- ice-blue
        hl["@function.call"]   = { fg = "#B8D8E8" }
        hl.Function            = { fg = "#B8D8E8" }
        hl["@string"]          = { fg = "#3AE070" }               -- oled-green
        hl.String              = { fg = "#3AE070" }
        hl["@number"]          = { fg = "#D4A017" }               -- amber
        hl["@boolean"]         = { fg = "#D4A017" }
        hl.Number              = { fg = "#D4A017" }
        hl.Boolean             = { fg = "#D4A017" }
        hl["@type"]            = { fg = "#4A9EF5" }               -- oled-blue
        hl["@type.builtin"]    = { fg = "#4A9EF5" }
        hl.Type                = { fg = "#4A9EF5" }
        hl["@variable"]        = { fg = "#E8E8EA" }               -- text-primary
        hl["@parameter"]       = { fg = "#E8DFC0" }               -- label-cream
        hl["@property"]        = { fg = "#A8ADB3" }               -- chrome-silver
        hl.Comment             = { fg = "#8A8D93", italic = true } -- text-muted

        -- Pmenu
        hl.Pmenu        = { bg = "#1C1D1F", fg = "#E8E8EA" }
        hl.PmenuSel     = { bg = "#2E3034", fg = "#E8B830", bold = true }
        hl.PmenuBorder  = { fg = "#3A3D42" }

        -- Floats / Telescope
        hl.NormalFloat      = { bg = "#1C1D1F" }
        hl.FloatBorder      = { fg = "#3A3D42", bg = "#1C1D1F" }
        hl.TelescopeBorder  = { fg = "#3A3D42" }
        hl.TelescopeSelection = { bg = "#2E3034", fg = "#E8B830" }
        hl.TelescopeMatching  = { fg = "#E8B830", bold = true }

        -- Diagnostics
        hl.DiagnosticError = { fg = "#E84040" }
        hl.DiagnosticWarn  = { fg = "#D4A017" }
        hl.DiagnosticInfo  = { fg = "#4A9EF5" }
        hl.DiagnosticHint  = { fg = "#B8D8E8" }

        -- Git signs
        hl.GitSignsAdd    = { fg = "#3AE070" }
        hl.GitSignsChange = { fg = "#D4A017" }
        hl.GitSignsDelete = { fg = "#E84040" }

        -- Snacks dashboard (LazyVim logo)
        hl.SnacksDashboardHeader = { fg = "#E8B830", bold = true }
        hl.SnacksDashboardTitle  = { fg = "#E8B830" }
        hl.SnacksDashboardIcon   = { fg = "#E8B830" }
        hl.SnacksDashboardKey    = { fg = "#D4A017" }
      end,
    },
  },

  -- Set tokyonight-night as the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },

  -- Lualine with Shargeek colors
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = {
          normal = {
            a = { bg = "#E8B830", fg = "#111113", gui = "bold" },
            b = { bg = "#2E3034", fg = "#E8E8EA" },
            c = { bg = "#1C1D1F", fg = "#8A8D93" },
          },
          insert = {
            a = { bg = "#3AE070", fg = "#111113", gui = "bold" },
          },
          visual = {
            a = { bg = "#4A9EF5", fg = "#111113", gui = "bold" },
          },
          replace = {
            a = { bg = "#E84040", fg = "#111113", gui = "bold" },
          },
          command = {
            a = { bg = "#D4A017", fg = "#111113", gui = "bold" },
          },
          inactive = {
            a = { bg = "#1C1D1F", fg = "#8A8D93" },
            b = { bg = "#1C1D1F", fg = "#8A8D93" },
            c = { bg = "#1C1D1F", fg = "#8A8D93" },
          },
        },
      },
    },
  },
}
