return {
	"goolord/alpha-nvim",

	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.startify")

		dashboard.section.header.val = {
			"nvim",
		}

		dashboard.section.header.opts = {
			position = "center",
			hl = "Comment",
		}

		alpha.setup(dashboard.opts)
	end,
}
