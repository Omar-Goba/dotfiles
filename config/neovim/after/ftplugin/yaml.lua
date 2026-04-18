-- Make gq/gqq wrap text and comments in YAML buffers.
vim.bo.formatexpr = ""
vim.bo.textwidth = 88

vim.api.nvim_create_autocmd("LspAttach", {
	buffer = 0,
	callback = function()
		vim.bo.formatexpr = ""
	end,
})

local function format_yaml_block()
	local cur = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.fn.indent(cur)

	if indent == 0 or vim.fn.getline(cur):match("^%s*$") then
		vim.cmd("normal! gqq")
		return
	end

	local start_line = cur
	while start_line > 1 do
		local prev = start_line - 1
		local prev_text = vim.fn.getline(prev)
		if prev_text:match("^%s*$") or vim.fn.indent(prev) < indent then
			break
		end
		start_line = prev
	end

	local end_line = cur
	local last_line = vim.fn.line("$")
	while end_line < last_line do
		local nxt = end_line + 1
		local nxt_text = vim.fn.getline(nxt)
		if nxt_text:match("^%s*$") or vim.fn.indent(nxt) < indent then
			break
		end
		end_line = nxt
	end

	local old_indentexpr = vim.bo.indentexpr
	vim.bo.indentexpr = ""
	vim.cmd(("normal! %dGV%dGgq"):format(start_line, end_line))
	vim.bo.indentexpr = old_indentexpr
end

vim.keymap.set("n", "gqq", format_yaml_block, {
	buffer = true,
	desc = "Format YAML block",
})
