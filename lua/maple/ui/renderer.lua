local api = vim.api
local window = require('maple.ui.window')

local M = {}

function M.render_notes(notes_data)
	local buf = window.get_buf()
	local win = window.get_win()

	local lines = {}
	local content = notes_data.content or ""

	if content and content ~= "" then
		local s = content:gsub("\r\n", "\n"):gsub("\r", "\n")
		local current_pos = 1
		while current_pos <= #s do
			local nl_pos = s:find("\n", current_pos, true)
			if nl_pos then
				table.insert(lines, s:sub(current_pos, nl_pos - 1))
				current_pos = nl_pos + 1
			else
				table.insert(lines, s:sub(current_pos))
				break
			end
		end
	end

	if #lines == 0 then
		table.insert(lines, "")
	end

	-- Update window title
	window.update_title()

	-- Fill the buffer with the content
	api.nvim_buf_set_option(buf, 'modifiable', true)
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set window scrolloff
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_set_option(win, 'scrolloff', 3)
	end

	-- Update winbar
	local ok, statusline = pcall(require, 'maple.ui.statusline')
	if ok then
		statusline.update()
	end
end

function M.get_notes_content()
	local buf = window.get_buf()
	local win = window.get_win()

	if not win or not api.nvim_win_is_valid(win) then
		return ""
	end

	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

	while #lines > 0 and lines[#lines] == "" do
		table.remove(lines)
	end

	return table.concat(lines, "\n")
end

return M
