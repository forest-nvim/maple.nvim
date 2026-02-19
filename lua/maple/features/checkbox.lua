local api = vim.api
local window = require('maple.ui.window')

local M = {}

local CHECKBOX_PATTERN = "^(%s*)([-*])(%s+)%[([x%s])%](.*)$"

--- Toggle the checkbox on the current line.
--- If the line has a checkbox, flip between [ ] and [x].
--- If the line has no checkbox, prepend "- [ ] " to it.
function M.toggle()
	local buf = window.get_buf()
	if not buf or not api.nvim_buf_is_valid(buf) then
		return
	end

	local row = api.nvim_win_get_cursor(0)[1] - 1
	local line = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	if not line then
		return
	end

	local indent, marker, gap, state, rest = line:match(CHECKBOX_PATTERN)

	if state then
		local new_state = (state == "x") and " " or "x"
		local new_line = indent .. marker .. gap .. "[" .. new_state .. "]" .. rest
		api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
	else
		local leading = line:match("^(%s*)") or ""
		local content = line:sub(#leading + 1)
		local new_line = leading .. "- [ ] " .. content
		api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
	end
end

--- Insert a new "- [ ] " line below the cursor and enter insert mode.
function M.insert()
	local buf = window.get_buf()
	if not buf or not api.nvim_buf_is_valid(buf) then
		return
	end

	local row = api.nvim_win_get_cursor(0)[1]
	local cur_line = api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
	local indent = cur_line:match("^(%s*)") or ""
	local new_line = indent .. "- [ ] "

	api.nvim_buf_set_lines(buf, row, row, false, { new_line })
	api.nvim_win_set_cursor(0, { row + 1, #new_line })
	vim.cmd("startinsert!")
end

return M
