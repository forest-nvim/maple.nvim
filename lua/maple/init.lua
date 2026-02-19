local M = {}
local api = vim.api
local config = require('maple.config')
local storage = require('maple.storage')
local window = require('maple.ui.window')
local renderer = require('maple.ui.renderer')

M._setup_called = false

function M.setup(user_config)
	M._setup_called = true
	config.setup(user_config or {})
end

local function ensure_setup()
	if not M._setup_called then
		M.setup({})
	end
end

local function setup_autosave()
	local buf = window.get_buf()
	local save_augroup = api.nvim_create_augroup("MapleNotesSave", { clear = true })

	api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
		group = save_augroup,
		buffer = buf,
		callback = function()
			local content = renderer.get_notes_content()
			storage.save_notes({ content = content })
		end,
	})

	api.nvim_create_autocmd("BufWipeout", {
		group = save_augroup,
		buffer = buf,
		callback = function()
			window.reset()
		end,
	})
end

local function is_open()
	local win = window.get_win()
	local buf = window.get_buf()
	return win
		and api.nvim_win_is_valid(win)
		and buf
		and api.nvim_buf_is_valid(buf)
		and api.nvim_win_get_buf(win) == buf
end

function M.toggle(style_override)
	ensure_setup()

	if is_open() then
		M.close()
		return
	end

	local notes = storage.load_notes()
	window.create_buf()
	window.create_win(style_override)

	local buf = window.get_buf()
	api.nvim_buf_set_option(buf, 'modifiable', true)
	renderer.render_notes(notes)
	setup_autosave()

	-- q to close in normal mode
	api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
		noremap = true,
		silent = true,
		callback = function() M.close() end,
	})
end

function M.close()
	local win = window.get_win()
	if win and api.nvim_win_is_valid(win) then
		local content = renderer.get_notes_content()
		storage.save_notes({ content = content })
		window.close_win()
	end
end

function M.switch_mode()
	local win = window.get_win()
	if not win or not api.nvim_win_is_valid(win) then
		return
	end

	local content = renderer.get_notes_content()
	storage.save_notes({ content = content })

	if config.options.notes_mode == "global" then
		config.options.notes_mode = "project"
	else
		config.options.notes_mode = "global"
	end

	storage.reset()
	local new_notes = storage.load_notes()

	api.nvim_buf_set_option(window.get_buf(), 'modifiable', true)
	renderer.render_notes(new_notes)
end

function M.toggle_checkbox()
	require('maple.features.checkbox').toggle()
end

function M.add_checkbox()
	require('maple.features.checkbox').insert()
end

-- Search notes with Telescope
function M.search_notes(picker_name)
	ensure_setup()

	local has_telescope, telescope = pcall(require, 'telescope')
	if not has_telescope then
		vim.notify("Maple: telescope.nvim is required for :MapleSearch", vim.log.levels.WARN)
		return
	end

	pcall(telescope.load_extension, 'maple')
	if picker_name == "grep" then
		telescope.extensions.maple.grep()
	else
		telescope.extensions.maple.maple()
	end
end

return M
