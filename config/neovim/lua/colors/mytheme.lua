-- Homebrew-Inspired Neovim Theme: Minimalist Retro Terminal
-- Tailored for Omar Y. Goba (CTerm-only)

local M = {}

local palette = {
	-- Base
	bg = "Black",
	fg = "Green",
	bg_alt = "LightGray",
	bg_highlight = "Black",

	-- Core Green Shades
	green_bright = "LightGreen",
	green_dim = "Green",
	green_muted = "DarkGreen",

	-- Accent Colors
	yellow = "Yellow",
	blue = "Blue",
	purple = "Magenta",
	dark_purple = "DarkMagenta",
	cyan = "Cyan",

	-- UI Specific
	comment = "DarkCyan",
	line_nr = "Yellow",
	cursor = "LightGreen",
	visual = "DarkCyan",
	pmenu = "Black",

	-- Alerts
	red = "Red",
}

-- Highlight helper: only sets CTerm attributes
local function hl(group, opts)
	opts = opts or {}
	vim.api.nvim_set_hl(0, group, {
		ctermfg = opts.ctermfg,
		ctermbg = opts.ctermbg,
		bold = opts.bold,
		italic = opts.italic,
		underline = opts.underline,
	})
end

function M.setup()
	-- Reset any existing syntax highlights to a clean state
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	-- Turn off true-color; we’ll rely solely on cterm (ANSI) colors
	vim.opt.termguicolors = false

	-- UI -----------------------------------------------------------------------

	-- Normal: the default text and background for all buffers
	hl("Normal", { ctermfg = palette.fg, ctermbg = palette.bg })

	-- NormalFloat: text and background inside floating windows (e.g. hover popups)
	hl("NormalFloat", { ctermfg = palette.fg, ctermbg = palette.bg_alt })

	-- Cursor: the cursor itself (inverted colors for visibility)
	hl("Cursor", { ctermfg = palette.bg, ctermbg = palette.cursor })

	-- CursorLine: background of the line under the cursor
	hl("CursorLine", { ctermbg = palette.bg_alt })

	-- CursorColumn: background of the column under the cursor
	hl("CursorColumn", { ctermbg = palette.bg_alt })

	-- LineNr: line numbers in the gutter
	hl("LineNr", { ctermfg = palette.line_nr })

	-- Visual: background color when selecting text in visual mode
	hl("Visual", { ctermbg = palette.visual })

	-- StatusLine: text and background of the status line
	hl("StatusLine", { ctermfg = palette.green_bright, ctermbg = palette.bg_alt })

	-- VertSplit: the vertical separator between windows
	hl("VertSplit", { ctermfg = palette.green_dim })

	-- Pmenu: popup menu (e.g. completion list) text and background
	hl("Pmenu", { ctermfg = palette.fg, ctermbg = palette.pmenu })

	-- PmenuSel: selected item in the popup menu
	hl("PmenuSel", { ctermfg = palette.bg, ctermbg = palette.green_bright })

	-- Comment: comment text color and italic style
	hl("Comment", { ctermfg = palette.comment })

	-- Fold styling
	hl("Folded", { ctermfg = palette.dark_purple, ctermbg = palette.bg })
	hl("FoldColumn", { ctermfg = palette.green_dim, ctermbg = palette.bg })

	-- Syntax Highlighting ------------------------------------------------------

	-- String: literal strings in code
	hl("String", { ctermfg = palette.yellow })

	-- Number: numeric literals
	hl("Number", { ctermfg = palette.cyan })

	-- Boolean: boolean literals, shown bold for emphasis
	hl("Boolean", { ctermfg = palette.cyan, bold = true })

	-- Keyword: language keywords (e.g. if, for)
	hl("Keyword", { ctermfg = palette.purple })

	-- Identifier: user-defined names (variables, constants)
	hl("Identifier", { ctermfg = palette.fg })

	-- Statement: statements like return, break
	hl("Statement", { ctermfg = palette.yellow })

	-- Type: type names (e.g. int, String)
	hl("Type", { ctermfg = palette.cyan })

	-- Function: function and method names, bold for emphasis
	hl("Function", { ctermfg = palette.cyan, bold = true })
	-- Ensure Python builtins (print, len, etc.) use our cyan bold style
	hl("pythonBuiltin", { ctermfg = palette.cyan, bold = true })

	-- Operator: operators (+, -, =, etc.)
	hl("Operator", { ctermfg = palette.fg })
end

return M
