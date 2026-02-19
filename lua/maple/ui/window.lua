local api = vim.api
local config = require("maple.config")

local M = {}

local buf = nil
local win = nil
local prev_buf = nil
local active_style = nil

function M.create_buf()
	buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "modifiable", true)
	api.nvim_buf_set_option(buf, "filetype", "markdown")
	return buf
end

local function get_title()
	local mode_text = config.options.notes_mode == "global" and "Global Notes" or "Project Notes"
	local title = config.options.title or " maple "
	return string.format(" %s (%s) ", vim.trim(title), mode_text)
end

local function create_float_win()
	local width = math.floor(vim.o.columns * config.options.width)
	local height = math.floor(vim.o.lines * config.options.height)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = config.options.border,
		title = get_title(),
		title_pos = config.options.title_pos,
	}

	win = api.nvim_open_win(buf, true, opts)
end

local function create_split_win()
	local height = math.floor(vim.o.lines * config.options.height)
	vim.cmd("botright " .. height .. "split")
	win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, buf)
end

local function create_vsplit_win()
	local width = math.floor(vim.o.columns * config.options.width)
	vim.cmd("botright " .. width .. "vsplit")
	win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, buf)
end

local function create_buffer_win()
	prev_buf = api.nvim_get_current_buf()
	win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, buf)
end

local function setup_win_options()
	local highlights = require("maple.ui.highlights")
	highlights.setup()
	highlights.apply_to_window(win, active_style)

	if active_style == "float" then
		api.nvim_win_set_option(win, "winblend", config.options.winblend)
	end

	api.nvim_win_set_option(win, "wrap", true)
	api.nvim_win_set_option(win, "linebreak", true)

	if config.options.relative_number then
		api.nvim_win_set_option(win, "relativenumber", true)
	else
		api.nvim_win_set_option(win, "number", true)
	end

	api.nvim_win_set_option(win, "scrolloff", 3)

	local statusline = require("maple.ui.statusline")
	statusline.define_highlights()
	statusline.update()
	statusline.setup_autocommands()
end

function M.update_title()
	if not win or not api.nvim_win_is_valid(win) then
		return
	end

	if active_style ~= "float" then
		return
	end

	local opts = {
		title = get_title(),
		title_pos = config.options.title_pos,
	}
	api.nvim_win_set_config(win, opts)
end

function M.create_win(style_override)
	active_style = style_override or config.options.open_style
	local style = active_style

	if style == "split" then
		create_split_win()
	elseif style == "vsplit" then
		create_vsplit_win()
	elseif style == "buffer" then
		create_buffer_win()
	else
		create_float_win()
	end

	setup_win_options()
	return win
end

function M.close_win()
	if not win or not api.nvim_win_is_valid(win) then
		win = nil
		prev_buf = nil
		return
	end

	if active_style == "buffer" then
		if prev_buf and api.nvim_buf_is_valid(prev_buf) then
			api.nvim_win_set_buf(win, prev_buf)
		else
			api.nvim_win_set_buf(win, api.nvim_create_buf(true, false))
		end
	else
		api.nvim_win_close(win, true)
	end

	win = nil
	prev_buf = nil
	active_style = nil
end

function M.reset()
	win = nil
	buf = nil
	prev_buf = nil
	active_style = nil
end

function M.get_buf()
	return buf
end

function M.get_win()
	return win
end

return M
