local api = vim.api
local config = require("maple.config")
local window -- lazy-loaded to avoid circular require

local M = {}

local function get_window()
	if not window then
		window = require("maple.ui.window")
	end
	return window
end

function M.define_highlights()
	api.nvim_set_hl(0, "MapleWinBarMode", { link = "Statement", default = true })
	api.nvim_set_hl(0, "MapleWinBarName", { link = "Title", default = true })
	api.nvim_set_hl(0, "MapleWinBarInfo", { link = "Comment", default = true })
end

local function count_words_and_lines()
	local win_mod = get_window()
	local buf = win_mod.get_buf()
	if not buf or not api.nvim_buf_is_valid(buf) then
		return 0, 0
	end
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
	local word_count = 0
	for _, line in ipairs(lines) do
		for _ in line:gmatch("%S+") do
			word_count = word_count + 1
		end
	end
	return word_count, #lines
end

function M.build_winbar()
	local mode = config.options.notes_mode or "project"
	local mode_label = mode == "global" and "Global" or "Project"
	local words, lines = count_words_and_lines()

	local left = string.format("%%#MapleWinBarMode# %s ", mode_label)
	local center = "%#MapleWinBarName# Notes "
	local right = string.format("%%#MapleWinBarInfo# %dw %dL ", words, lines)

	return left .. "%=" .. center .. "%=" .. right
end

function M.update()
	if not config.options.show_winbar then
		local win_mod = get_window()
		local win = win_mod.get_win()
		if win and api.nvim_win_is_valid(win) then
			vim.wo[win].winbar = ""
		end
		return
	end
	local win_mod = get_window()
	local win = win_mod.get_win()
	if not win or not api.nvim_win_is_valid(win) then
		return
	end
	vim.wo[win].winbar = M.build_winbar()
end

function M.setup_autocommands()
	local win_mod = get_window()
	local buf = win_mod.get_buf()
	if not buf or not api.nvim_buf_is_valid(buf) then
		return
	end
	local group = api.nvim_create_augroup("MapleWinBar", { clear = true })
	api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		buffer = buf,
		callback = function()
			M.update()
		end,
	})
	api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			M.define_highlights()
			M.update()
		end,
	})
end

return M
