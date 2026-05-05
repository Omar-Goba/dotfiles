local mapping_key_prefix = vim.g.ai_prefix_key or "<leader>c"

-- get the prompts
local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

local SYSTEM_PROMPT = read_file("/Users/omar_yasser/.config/neovim/lua/plugins/prompts/system.txt")
local COPILOT_REVIEW = read_file("/Users/omar_yasser/.config/neovim/lua/plugins/prompts/review.txt")
local COPILOT_EXPLAIN = read_file("/Users/omar_yasser/.config/neovim/lua/plugins/prompts/explain.txt")
local COPILOT_REFACTOR = read_file("/Users/omar_yasser/.config/neovim/lua/plugins/prompts/refactor.txt")
local PROMPT_COMMIT = read_file("/Users/omar_yasser/.config/neovim/lua/plugins/prompts/commit.txt")

return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
		"nvim-telescope/telescope.nvim", -- Optional: For using slash commands
		"jellydn/spinner.nvim", -- Show loading spinner when request is started
	},
	config = function(_, options)
		require("codecompanion").setup(options)

		-- Show loading spinner when request is started
		local spinner = require("spinner")
		local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
		vim.api.nvim_create_autocmd({ "User" }, {
			pattern = "CodeCompanionRequest*",
			group = group,
			callback = function(request)
				if request.match == "CodeCompanionRequestStarted" then
					spinner.show()
				end
				if request.match == "CodeCompanionRequestFinished" then
					spinner.hide()
				end
			end,
		})
	end,
	opts = {
		adapters = {
			code_gemma2b = function()
				return require("codecompanion.adapters").extend("ollama", {
					name = "code_gemma2b",
					schema = {
						model = {
							default = "codegemma:2b",
						},
						num_ctx = {
							default = 16384,
						},
						num_predict = {
							default = 1,
						},
					},
				})
			end,
			llama3_1_8B = function()
				return require("codecompanion.adapters").extend("ollama", {
					name = "llama3_1_8B",
					schema = {
						model = {
							default = "llama3.1:8b",
						},
					},
				})
			end,
			qwen2_5_coder_7B = function()
				return require("codecompanion.adapters").extend("ollama", {
					name = "qwen2_5_coder_7B",
					schema = {
						model = {
							default = "qwen2.5-coder:7b",
						},
						num_ctx = {
							default = 16384,
						},
					},
				})
			end,
		},
		strategies = {
			chat = {
				adapter = "qwen2_5_coder_7B",
				roles = { llm = "slave", user = "master" },
				keymaps = {
					send = {
						modes = {
							n = "<CR>",
							i = "<M-CR>",
						},
						index = 1,
						callback = "keymaps.send",
						description = "Send",
					},
					close = {
						modes = {
							n = "q",
						},
						index = 3,
						callback = "keymaps.close",
						description = "Close Chat",
					},
					stop = {
						modes = {
							n = "<C-c>",
						},
						index = 4,
						callback = "keymaps.stop",
						description = "Stop Request",
					},
				},
			},
			inline = {
				adapter = "qwen2_5_coder_7B",
			},
		},
		display = {
			chat = {
				window = {
					layout = "float", -- float|vertical|horizontal|buffer
				},
				intro_message = "Welcome to CodeCompanion ✨! Press ? for option",
				show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
				separator = "─", -- The separator between the different messages in the chat buffer
				show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
				show_settings = true, -- Show LLM settings at the top of the chat buffer?
				show_token_count = true, -- Show the token count for each response?
				start_in_insert_mode = false, -- Open the chat buffer in insert mode?
			},
		},
		prompt_library = {
			-- Custom the default prompt
			["Generate a Commit Message"] = {
				prompts = {
					{
						role = "system",
						content = PROMPT_COMMIT,
						opts = {
							visible = true,
						},
					},
					{
						role = "user",
						content = function()
							local diff = vim.fn.system("git diff --staged")
							if vim.trim(diff) == "" then
								diff = "No unstaged changes available."
							end
							return "```\n" .. diff .. "\n```"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Explain"] = {
				strategy = "chat",
				description = "Explain how code in a buffer works",
				opts = {
					default_prompt = true,
					modes = { "v" },
					short_name = "explain",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_EXPLAIN,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please explain how the following code works:\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Explain Code"] = {
				strategy = "chat",
				description = "Explain how code works",
				opts = {
					short_name = "explain-code",
					auto_submit = false,
					is_slash_cmd = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_EXPLAIN,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = [[Please explain how the following code works.]],
					},
				},
			},
			-- Add custom prompts
			["Inline Document"] = {
				strategy = "inline",
				description = "Add documentation for code.",
				opts = {
					modes = { "v", "x" },
					short_name = "inline-doc",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Document"] = {
				strategy = "chat",
				description = "Write documentation for code.",
				opts = {
					modes = { "v" },
					short_name = "doc",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please brief how it works and provide documentation in comment code for the following code. Also suggest to have better naming to improve readability.\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Review"] = {
				strategy = "chat",
				description = "Review the provided code snippet.",
				opts = {
					modes = { "v" },
					short_name = "review",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_REVIEW,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability:\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Review Code"] = {
				strategy = "chat",
				description = "Review code and provide suggestions for improvement.",
				opts = {
					short_name = "review-code",
					auto_submit = false,
					is_slash_cmd = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_REVIEW,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability.",
					},
				},
			},
			["Refactor"] = {
				strategy = "inline",
				description = "Refactor the provided code snippet.",
				opts = {
					modes = { "v" },
					short_name = "refactor",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_REFACTOR,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please refactor the following code to improve its clarity and readability:\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Refactor Code"] = {
				strategy = "chat",
				description = "Refactor the provided code snippet.",
				opts = {
					short_name = "refactor-code",
					auto_submit = false,
					is_slash_cmd = true,
				},
				prompts = {
					{
						role = "system",
						content = COPILOT_REFACTOR,
						opts = {
							visible = false,
						},
					},
					{
						role = "user",
						content = "Please refactor the following code to improve its clarity and readability.",
					},
				},
			},
			["Naming"] = {
				strategy = "inline",
				description = "Give betting naming for the provided code snippet.",
				opts = {
					modes = { "v" },
					short_name = "naming",
					auto_submit = true,
					user_prompt = false,
					stop_context_insertion = true,
				},
				prompts = {
					{
						role = "user",
						content = function(context)
							local code =
								require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

							return "Please provide better names for the following variables and functions:\n\n```"
								.. context.filetype
								.. "\n"
								.. code
								.. "\n```\n\n"
						end,
						opts = {
							contains_code = true,
						},
					},
				},
			},
			["Better Naming"] = {
				strategy = "chat",
				description = "Give betting naming for the provided code snippet.",
				opts = {
					short_name = "better-naming",
					auto_submit = false,
					is_slash_cmd = true,
				},
				prompts = {
					{
						role = "user",
						content = "Please provide better names for the following variables and functions.",
					},
				},
			},
		},
	},
	keys = {
		-- Recommend setup
		{
			mapping_key_prefix .. "a",
			"<cmd>CodeCompanionActions<cr>",
			desc = "Code Companion - Actions",
		},
		{
			mapping_key_prefix .. "v",
			"<cmd>CodeCompanionChat Toggle<cr>",
			desc = "Code Companion - Toggle",
			mode = { "n", "v", "x" },
		},
		-- Some common usages with visual mode
		{
			mapping_key_prefix .. "e",
			"<cmd>CodeCompanion /explain<cr>",
			desc = "Code Companion - Explain code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "f",
			"<cmd>CodeCompanion /fix<cr>",
			desc = "Code Companion - Fix code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "l",
			"<cmd>CodeCompanion /lsp<cr>",
			desc = "Code Companion - Explain LSP diagnostic",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "t",
			"<cmd>CodeCompanion /tests<cr>",
			desc = "Code Companion - Generate unit test",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "m",
			"<cmd>CodeCompanion /commit<cr>",
			desc = "Code Companion - Git commit message",
		},
		-- Custom prompts
		{
			mapping_key_prefix .. "d",
			"<cmd>CodeCompanion /inline-doc<cr>",
			desc = "Code Companion - Inline document code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "D",
			"<cmd>CodeCompanion /doc<cr>",
			desc = "Code Companion - Document code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "r",
			"<cmd>CodeCompanion /refactor<cr>",
			desc = "Code Companion - Refactor code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "R",
			"<cmd>CodeCompanion /review<cr>",
			desc = "Code Companion - Review code",
			mode = { "n", "v", "x" },
		},
		{
			mapping_key_prefix .. "n",
			"<cmd>CodeCompanion /naming<cr>",
			desc = "Code Companion - Better naming",
			mode = { "n", "v", "x" },
		},
	},
}
