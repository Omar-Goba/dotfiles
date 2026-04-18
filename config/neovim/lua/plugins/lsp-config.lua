return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		local lspconfig = require("lspconfig")

		-- show source of the diagnostic
		vim.diagnostic.config({
			virtual_text = {
				source = "always",
			},
			float = {
				source = "always",
			},
		})

		-- LSPs
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			filetypes = { "lua" },
		})

		-- lspconfig.pyright.setup({
		--   capabilities = capabilities,
		--   filetypes = { "python" },
		-- })

		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
			filetypes = {
				"xml",
				"html",
				"css",
				"scss",
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
			},
		})

		lspconfig.eslint.setup({
			capabilities = capabilities,
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			settings = {
				workingDirectory = { mode = "auto" },
				format = { enable = true },
				lint = { enable = true },
			},
		})

		lspconfig.clangd.setup({
			capabilities = capabilities,
			filetypes = { "c", "cpp" },
		})

		lspconfig.ruff.setup({
			capabilities = capabilities,
			filetypes = { "python" },
		})

		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
			filetypes = { "rust" },
			root_dir = lspconfig.util.root_pattern("Cargo.toml"),
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})

		lspconfig.gleam.setup({
			capabilities = capabilities,
			filetypes = { "gleam" },
		})

		-- lspconfig.texlab.setup({
		-- 	capabilities = capabilities,
		-- 	filetypes = { "tex" },
		-- })

		lspconfig.terraformls.setup({
			capabilities = capabilities,
			filetypes = { "terraform", "tf", "tfvars" },
		})

		lspconfig.yamlls.setup({
			capabilities = capabilities,
			filetypes = { "yaml", "yml" },
			settings = {
				yaml = {
					validate = true,
					hover = true,
					completion = true,
					format = { enable = false },
					schemaStore = {
						enable = true,
						url = "https://www.schemastore.org/api/json/catalog.json",
					},
					schemas = {
						kubernetes = "*.yaml",
						["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
						["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
					},
				},
			},
		})
	end,
}
