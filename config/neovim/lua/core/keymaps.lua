-- init some vars to make code clean
local k = vim.keymap

-- map the semicolon to colon
k.set("n", ";", ":", { desc = "Map semicolon to colon" })

-- quick save
k.set("n", "<leader>w", ":w<CR>", { desc = "Quick save" })

-- copy to clipboard
k.set({ "n", "v" }, "<c-c>", '"+y', { desc = "Copy to clipboard" })

-- copy the current file path
k.set("n", "<leader>cp", ":let @+=expand('%:p')<CR>", { desc = "Copy file path" })

-- navigate vim panes better
k.set("n", "<c-k>", ":wincmd k<CR>", { desc = "Move up between panes" })
k.set("n", "<c-j>", ":wincmd j<CR>", { desc = "Move down between panes" })
k.set("n", "<c-h>", ":wincmd h<CR>", { desc = "Move left between panes" })
k.set("n", "<c-l>", ":wincmd l<CR>", { desc = "Move right between panes" })

-- resize panes
k.set("n", "<M-h>", ":vertical resize -5<CR>", { desc = "Resize pane left" })
k.set("n", "<M-j>", ":resize +5<CR>", { desc = "Resize pane down" })
k.set("n", "<M-k>", ":resize -5<CR>", { desc = "Resize pane up" })
k.set("n", "<M-l>", ":vertical resize +5<CR>", { desc = "Resize pane right" })

-- init a terminal buffer
k.set("n", "<leader>tt", ":below 10sp term://zsh<CR>", { desc = "Open terminal in a pane" })
k.set("n", "<leader>TT", ":tabedit<CR>:term<CR>", { desc = "Open terminal in a tab" })
k.set("t", "<esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
k.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move left in terminal" })
k.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move down in terminal" })
k.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move up in terminal" })
k.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move right in terminal" })

-- remove search highlight
k.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Remove search highlight" })

-- toggle line wrap
k.set("n", "<leader>l", ":set wrap!<CR>", { desc = "Toggle line wrap" })

-- navigate buffers better
k.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
k.set("n", "<leader>x", ":close<CR>", { desc = "Close window" })

k.set("n", "<leader>en", ":enew<CR>", { desc = "New empty buffer" })
k.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })
k.set("n", "<leader>bp", ":bp<CR>", { desc = "Previous buffer" })
k.set("n", "<leader>bn", ":bn<CR>", { desc = "Next buffer" })

-- toggle relative line numbers
k.set("n", "<leader>r", ":set rnu!<CR>", { desc = "Toggle relative line numbers" })

-- spell checker
k.set("n", "<leader>S", ":setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spell checker" })
k.set("n", "<leader>s", "1z=", { desc = "Correct spelling" })

-- comment toggle
k.set("n", "<leader>/", function()
	require("Comment.api").toggle.linewise.current()
end, { desc = "Comment Toggle" })
k.set(
	"v",
	"<leader>/",
	"<ESC>:lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Comment Toggle" }
)

-- debugging
k.set("n", "<Leader>dt", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
k.set("n", "<Leader>dc", ":DapContinue<CR>", { desc = "Debugging: Continue" })
k.set("n", "<Leader>dx", ":DapTerminate<CR>", { desc = "Debugging: Terminate" })
k.set("n", "<Leader>di", ":DapStepInto<CR>", { desc = "Debugging: Step into" })
k.set("n", "<Leader>do", ":DapStepOver<CR>", { desc = "Debugging: Step over" })
k.set("n", "<Leader>dd", ":DapStepOut<CR>", { desc = "Debugging: Step out" })
k.set("n", "<Leader>dr", ":DapRestartFrame<CR>", { desc = "Debugging: Restart frame" })

-- git
k.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview git changes" })
k.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })

-- lSP
k.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
k.set("n", "<leader>fd", vim.diagnostic.open_float, { desc = "Open float diagnostics" })
k.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
k.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
k.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
k.set("n", "<leader>fm", vim.lsp.buf.format, { desc = "Format document" })
k.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

-- neotree
k.set("n", "<C-n>", ":Neotree filesystem toggle float<CR>", { desc = "Toggle filesystem floating" })
k.set("n", "<C-b>", ":Neotree buffers toggle float<CR>", { desc = "Reveal buffers floating" })

-- telescope
k.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
k.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep files" })
k.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })
k.set("n", "<leader>km", ":Telescope keymaps<CR>", { desc = "Keymaps" })
k.set("n", "<leader>gf", ":Telescope git_files<CR>", { desc = "Git files" })
k.set("n", "<leader>fr", function()
	require("telescope.builtin").lsp_references()
end, { noremap = true, silent = true, desc = "LSP find all references" })

-- lazygit
k.set("n", "<leader>lg", ":LazyGit<CR>", { desc = "LazyGit" })

-- code companion
-- nvim.api.nvim_set_keymap("v", "<Leader>ce", "", {
--   callback = function()
--     require("codecompanion").prompt("explain in one paragraph")
--   end,
--   noremap = true,
--   silent = true,
-- })

-- signature
local function insert_signature()
	local lines = {
		"  __   _,_ /_ __,",
		"_(_/__(_/_/_)(_/(_",
		" _/_",
		"(/",
	}

	local commentstring = vim.bo.commentstring:gsub("%%s", "") -- get the comment prefix only

	-- Prepend commentstring to each line
	for i, line in ipairs(lines) do
		lines[i] = commentstring .. " " .. line
	end

	-- Insert the commented lines
	vim.api.nvim_put(lines, "l", true, true)
end

vim.keymap.set("n", "<leader>sg", insert_signature, { desc = "Insert commented ASCII signature" })
