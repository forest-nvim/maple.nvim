local M = {}

-- Default configuration
M.defaults = {
	-- Appearance
	width = 0.6,
	height = 0.6,
	border = "rounded",
	title = " maple ",
	title_pos = "center",
	winblend = 10,
	show_winbar = true,
	relative_number = false,

	-- Storage
	storage_path = vim.fn.stdpath("data") .. "/maple",

	-- Notes management
	notes_mode = "project", -- "global" or "project"
	use_project_specific_notes = true,

	-- Preview
	preview = {
		enabled = true,
		width = 0.4,
		height = 0.3,
		winblend = 20,
	},

	-- Custom highlight overrides
	highlights = {},
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
	return M.options
end

return M
