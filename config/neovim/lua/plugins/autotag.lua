return {
	"windwp/nvim-ts-autotag",
	ft = {
		"javascript",
		"typescript",
		"typescriptreact",
		"javascriptreact",
	},
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}
