return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			ensure_installed = { "lua", "python", "javascript", "typescript", "tsx", "markdown", "dockerfile" },
			auto_install = true,
			ignore_install = { "tmux" },
			highlight = { enable = true },
			indent = { enable = true },
			playground = {
				enable = true,
				updatetime = 25,
			},
		})
	end,
}
