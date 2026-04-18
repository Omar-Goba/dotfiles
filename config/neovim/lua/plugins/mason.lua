return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
				require("mason-lspconfig").setup({
					ensure_installed = {
						"lua_ls",
						"pyright",
						"ruff",
						"clangd",
						"rust_analyzer",
						"eslint@4.8.0",
						"tailwindcss",
						"texlab",
						"terraformls",
						"yamlls",
					},
				})
			end,
		},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
				require("mason-null-ls").setup({
					ensure_installed = {
						"stylua",
						"mypy",
						"black",
						"clang-format",
						"prettierd",
						"yamllint",
						"latexindent",
					},
				})
			end,
	},
}
