-- Gado --
-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("tokyonight").setup({
-- 			on_highlights = function(hl, _)
-- 				hl.LineNr = {
-- 					fg = "#b2b8cf",
-- 				}
-- 			end,
-- 			transparent = true,
-- 		})
-- 		vim.cmd([[colorscheme tokyonight]])
-- 		-- colorscheme tokyonight-night
-- 	end,
-- }

-- Dracula --
-- return {
-- 	{
-- 		"scottmckendry/cyberdream.nvim",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			vim.o.background = "dark" -- Ensure dark mode is enabled
--
-- 			require("cyberdream").setup({
-- 				variant = "dark",
-- 				transparent = false,
-- 				saturation = 1,
-- 				italic_comments = false,
-- 				hide_fillchars = false,
-- 				borderless_pickers = false,
-- 				terminal_colors = true,
-- 				cache = false,
-- 				highlights = {
-- 					Normal = { bg = "#000000" },
-- 					NormalNC = { bg = "#000000" },
-- 					Comment = { fg = "#696969", bg = "NONE", italic = true },
-- 				},
-- 				colors = {
-- 					bg = "#000000",
-- 					green = "#00ff00",
-- 				},
-- 			})
--
-- 			vim.cmd("colorscheme cyberdream")
--
-- 			-- vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#000000" })
-- 			-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
-- 		end,
-- 	},
-- }

-- no theme
-- return {}

-- onedarkpro
return {
	"olimorris/onedarkpro.nvim",
	priority = 1000,
	config = function()
		vim.cmd("colorscheme onedark_dark")
	end,
}
