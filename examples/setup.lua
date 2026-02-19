-- Example configuration for maple.nvim
-- This file is provided as a reference to help you set up maple.nvim

-- Basic setup with default options
require('maple').setup()

-- Custom setup with all available options
require('maple').setup({
	-- Appearance
	width = 0.7,
	height = 0.8,
	border = 'double',
	title = ' My Notes ',
	title_pos = 'left',
	winblend = 15,
	show_winbar = true,
	relative_number = false,
	open_style = 'float', -- 'float', 'split', 'vsplit', or 'buffer'

	-- Storage
	storage_path = vim.fn.stdpath('data') .. '/maple',

	-- Notes management
	notes_mode = 'project',
	use_project_specific_notes = true,
})

-- Keybinds (set these however you like)
vim.keymap.set('n', '<leader>m', '<cmd>MapleToggle<CR>', { desc = 'Toggle Maple Notes' })
vim.keymap.set('n', '<leader>ms', '<cmd>MapleSwitchMode<CR>', { desc = 'Switch notes mode' })
vim.keymap.set('n', '<leader>mt', '<cmd>MapleToggleCheckbox<CR>', { desc = 'Toggle checkbox' })
vim.keymap.set('n', '<leader>ma', '<cmd>MapleAddCheckbox<CR>', { desc = 'Add checkbox' })
vim.keymap.set('n', '<leader>mf', '<cmd>MapleSearch<CR>', { desc = 'Search notes' })
vim.keymap.set('n', '<leader>mg', '<cmd>MapleSearch grep<CR>', { desc = 'Grep notes' })
