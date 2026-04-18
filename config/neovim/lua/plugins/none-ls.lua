return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local helpers = require("null-ls.helpers")
		local formatting = null_ls.builtins.formatting
		local diagnostics = null_ls.builtins.diagnostics

		local sources = {

				-- Lua formatting
				formatting.stylua,

				-- Python formatting
				formatting.black,
				--
				-- custom mypy with virtualenv support
				diagnostics.mypy.with({
					extra_args = function()
						-- local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
						local uv = vim.loop
						local cwd = uv.cwd()
						local venv_path = cwd .. "/.venv"

						-- Check if .venv exists and is a directory
						local stat = uv.fs_stat(venv_path)
						local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")

						if stat and stat.type == "directory" then
							if not virtual then
								virtual = venv_path
								-- Inject into environment variables
								vim.fn.setenv("VIRTUAL_ENV", virtual)
							end
						else
							-- Fallback if no .venv and no env vars
							virtual = virtual or "/usr"
						end
						-- print(vim.inspect(virtual))
						return { "--python-executable", virtual .. "/bin/python3" }
					end,
				}),

				-- C/C++ formatting
				formatting.clang_format,

				--
				formatting.prettierd,

				-- terraform formatting
				formatting.terraform_fmt,

				-- hadolint for Dockerfile linting
				diagnostics.hadolint,

				-- Latex formatting
				-- formatting.latexindent,
			}

		local yamllint_cmd = vim.fn.exepath("yamllint")
		if yamllint_cmd == "" then
			local mason_yamllint = vim.fn.stdpath("data") .. "/mason/bin/yamllint"
			if vim.fn.executable(mason_yamllint) == 1 then
				yamllint_cmd = mason_yamllint
			end
		end

		if yamllint_cmd ~= "" then
			table.insert(sources, diagnostics.yamllint.with({
				command = yamllint_cmd,
				filetypes = { "yaml", "yml" },
			}))
		end

		null_ls.setup({
			sources = sources,
		})

		-- Register custom dprint formatter for Dockerfiles
		null_ls.register({
			name = "dprint",
			method = null_ls.methods.FORMATTING,
			filetypes = { "dockerfile", "toml" },
			generator = helpers.formatter_factory({
				command = "dprint",
				args = { "fmt", "--stdin", "Dockerfile", "--config", "/Users/omar_yasser/.config/dprint/dprint.json" },
				to_stdin = true,
			}),
		})
	end,
}
