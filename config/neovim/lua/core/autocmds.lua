-- uiua filetype
vim.filetype.add({ extension = { ua = "uiua" } })

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.ua",
	callback = function(_)
		vim.cmd(([[
            silent! !uiua fmt %s
            mkview
            e
            loadview
        ]]):format(vim.fn.expand("<amatch>")))
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*" },
	callback = function()
		local filetype = vim.bo.filetype
		local allowed_filetypes = {
			"lua",
			"python",
			"javascript",
			"typescript",
			"json",
			"yaml",
			"html",
			"css",
			"scss",
			"markdown",
			"latex",
			"c",
			"cpp",
			"java",
			"rust",
			"go",
			"bash",
			"sh",
			"zsh",
			"vim",
			"lua",
			"yaml",
			"json",
			"html",
			"css",
			"scss",
			"markdown",
			"latex",
			"c",
			"cpp",
			"java",
		}
		vim.lsp.buf.format()
	end,
})

-- Markdown folding function
local function markdown_level()
	local line = vim.fn.getline(vim.v.lnum)

	-- Check header levels
	for level = 1, 6 do
		if line:match("^" .. string.rep("#", level) .. " ") then
			return ">" .. level
		end
	end

	return "="
end

-- Set up markdown folding autocommands
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.md",
	callback = function()
		vim.wo.foldexpr = "v:lua.markdown_level()"
		vim.wo.foldmethod = "expr"
	end,
})

-- Make the function available globally so foldexpr can access it
_G.markdown_level = markdown_level
