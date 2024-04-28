return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = true,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
}
