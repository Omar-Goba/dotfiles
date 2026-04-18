-- Make gq/gqq wrap text and comments in Python buffers.
vim.bo.formatexpr = ""
vim.bo.textwidth = 88

vim.api.nvim_create_autocmd("LspAttach", {
	buffer = 0,
	callback = function()
		vim.bo.formatexpr = ""
	end,
})
