local api = vim.api
local config = require("maple.config")

local M = {}

local buf = nil
local win = nil

function M.create_buf()
	buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "modifiable", true)
	api.nvim_buf_set_option(buf, "filetype", "markdown")
	return buf
end

function M.update_title()
	if not win or not api.nvim_win_is_valid(win) then
		return
	end

	local mode_text = config.options.notes_mode == "global" and "Global Notes" or "Project Notes"
	local title = config.options.title or " maple "
	local opts = {
		title = string.format(" %s (%s) ", vim.trim(title), mode_text),
		title_pos = config.options.title_pos,
	}
	api.nvim_win_set_config(win, opts)
end

function M.create_win()
	local width = math.floor(vim.o.columns * config.options.width)
	local height = math.floor(vim.o.lines * config.options.height)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local mode_text = config.options.notes_mode == "global" and "Global Notes" or "Project Notes"
	local title = config.options.title or " maple "

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = config.options.border,
		title = string.format(" %s (%s) ", vim.trim(title), mode_text),
		title_pos = config.options.title_pos,
	}

	win = api.nvim_open_win(buf, true, opts)

	-- Set up highlights
	local highlights = require("maple.ui.highlights")
	highlights.setup()
	highlights.apply_to_window(win)

	api.nvim_win_set_option(win, "winblend", config.options.winblend)
	api.nvim_win_set_option(win, "wrap", true)
	api.nvim_win_set_option(win, "linebreak", true)

	if config.options.relative_number then
		api.nvim_win_set_option(win, "relativenumber", true)
	else
		api.nvim_win_set_option(win, "number", true)
	end

	api.nvim_win_set_option(win, "scrolloff", 3)

	-- Set up winbar
	local statusline = require("maple.ui.statusline")
	statusline.define_highlights()
	statusline.update()
	statusline.setup_autocommands()

	return win
end

function M.close_win()
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
		win = nil
	end
end

function M.get_buf()
	return buf
end

function M.get_win()
	return win
end

return M
