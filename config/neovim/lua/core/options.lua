local g = vim.g
local opt = vim.opt

g.mapleader = " "
g.maplocalleader = " "

-- set syntax
vim.cmd("syntax enable")

-- set up colorscheme
opt.termguicolors = true

-- column and row limits
-- opt.colorcolumn = "80"
opt.scrolloff = 5

-- solve copilot tap map problem
g.copilot_assume_mapped = true

-- set up folding
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldmethod = "indent"
opt.foldenable = false
vim.wo.foldtext =
[[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'... (' . (v:foldend - v:foldstart + 1) . ' lines)']]
-- set the background color of the folds to black
-- local bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
-- local hl = vim.api.nvim_get_hl(0, { name = "Folded" })
-- hl.bg = bg
-- vim.api.nvim_set_hl(0, "Fold", hl)

-- make indents 2 spaces
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

-- make vim commands case insensitive
opt.ignorecase = true

-- show line numbers
opt.number = true
opt.relativenumber = true

-- show some invisible characters
opt.list = true

-- no line wrap
opt.wrap = false

-- show matching brackets
opt.undodir = "~/.vim/undodir"

-- some stuff for markdown
function OpenMarkdownPreview(url)
  vim.cmd("silent ! open -a safari -n --args --new-window " .. url)
end

g.mkdp_browserfunc = "OpenMarkdownPreview"
