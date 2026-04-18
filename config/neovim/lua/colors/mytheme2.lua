-- Lua Equivalent of relaxedgreen.vim (CTerm-only)

local M = {}

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
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.opt.termguicolors = false
	vim.opt.background = "dark"

	-- UI elements
	hl("Normal", { ctermfg = "Gray", ctermbg = "Black" })
	hl("Cursor", { ctermfg = "Green", ctermbg = "Blue" })
	hl("CursorIM", { ctermfg = "Black", ctermbg = "DarkGreen" })
	hl("CursorLine", { ctermbg = "DarkBlue" })
	hl("CursorColumn", { ctermbg = "DarkRed" })
	hl("LineNr", { ctermfg = "Green", bold = true })
	hl("MatchParen", { ctermbg = "Green" })
	hl("Visual", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("StatusLine", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("StatusLineNC", { ctermfg = "DarkGreen", ctermbg = "Blue" })
	hl("VertSplit", { ctermfg = "DarkGreen" })

	-- Menus and popups
	hl("Pmenu", { ctermfg = "Black", ctermbg = "Green" })
	hl("PmenuSel", { ctermfg = "Black", ctermbg = "Gray" })
	hl("PmenuSbar", { ctermfg = "Black", ctermbg = "Green" })
	hl("PmenuThumb", { ctermfg = "Gray", ctermbg = "Black" })

	-- Syntax groups
	hl("Comment", { ctermfg = "DarkCyan" })
	hl("Constant", { ctermfg = "Blue" })
	hl("String", { ctermfg = "Blue" }) -- Linked via Vim
	hl("Number", { ctermfg = "Blue" }) -- Linked via Vim
	hl("Boolean", { ctermfg = "Blue" }) -- Linked via Vim
	hl("Identifier", { ctermfg = "DarkCyan", underline = true })
	hl("Function", { ctermfg = "DarkGreen" })
	hl("Statement", { ctermfg = "DarkRed" })
	hl("Type", { ctermfg = "Green" })
	hl("PreProc", { ctermfg = "DarkGreen" })
	hl("Special", { ctermfg = "Green", bold = true })

	-- Diagnostics
	hl("Error", { ctermfg = "Black", ctermbg = "Red", bold = true })
	hl("ErrorMsg", { ctermfg = "White", ctermbg = "Red", bold = true })
	hl("WarningMsg", { ctermfg = "Black", ctermbg = "Yellow" })
	hl("SpellBad", { ctermfg = "Red", ctermbg = "Black", underline = true })
	hl("SpellCap", { ctermfg = "Yellow", ctermbg = "Black", underline = true })
	hl("SpellLocal", { ctermfg = "Blue", ctermbg = "Black", underline = true })
	hl("SpellRare", { ctermfg = "DarkGreen", ctermbg = "Black", underline = true })

	-- Diff
	hl("DiffAdd", { ctermfg = "Black", ctermbg = "Cyan" })
	hl("DiffDelete", { ctermfg = "Black", ctermbg = "Cyan" })
	hl("DiffChange", { ctermfg = "DarkGreen", ctermbg = "Black", underline = true })
	hl("DiffText", { ctermfg = "Green", ctermbg = "Black", bold = true })

	-- Others
	hl("Directory", { ctermfg = "Green", ctermbg = "Black" })
	hl("TabLine", { ctermfg = "Black", ctermbg = "Green" })
	hl("TabLineSel", { ctermfg = "Black", ctermbg = "Green" })
	hl("TabLineFill", { ctermfg = "Green", ctermbg = "Black" })
	hl("Title", { ctermfg = "Black", ctermbg = "Green" })
	hl("Todo", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("WildMenu", { ctermfg = "Blue", ctermbg = "DarkGreen" })
	hl("Folded", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("FoldColumn", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("SignColumn", { ctermfg = "DarkGreen", ctermbg = "Black" })
	hl("SpecialKey", { ctermfg = "Green", bold = true })
	hl("NonText", { ctermfg = "Brown" })

	-- Links (as commands)
	vim.cmd("highlight! link Character Constant")
	vim.cmd("highlight! link Number Constant")
	vim.cmd("highlight! link Boolean Constant")
	vim.cmd("highlight! link String Constant")
	vim.cmd("highlight! link Operator LineNr")
	vim.cmd("highlight! link Float Number")
	vim.cmd("highlight! link Define PreProc")
	vim.cmd("highlight! link Include PreProc")
	vim.cmd("highlight! link Macro PreProc")
	vim.cmd("highlight! link PreCondit PreProc")
	vim.cmd("highlight! link Repeat Question")
	vim.cmd("highlight! link Conditional Repeat")
	vim.cmd("highlight! link Delimiter Special")
	vim.cmd("highlight! link SpecialChar Special")
	vim.cmd("highlight! link SpecialComment Special")
	vim.cmd("highlight! link Tag Special")
	vim.cmd("highlight! link Exception Statement")
	vim.cmd("highlight! link Keyword Statement")
	vim.cmd("highlight! link Label Statement")
	vim.cmd("highlight! link StorageClass Type")
	vim.cmd("highlight! link Structure Type")
	vim.cmd("highlight! link Typedef Type")
end

return M
