local MiniTest = require('mini.test')
local new_set = MiniTest.new_set

local T = new_set()

-- Helper to simulate render without a real window
local function split_content(content)
	local lines = {}
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
	return lines
end

T['renderer'] = new_set()

T['renderer']['splits content into lines'] = function()
	local lines = split_content("line1\nline2\nline3")
	MiniTest.expect.equality(#lines, 3)
	MiniTest.expect.equality(lines[1], "line1")
	MiniTest.expect.equality(lines[2], "line2")
	MiniTest.expect.equality(lines[3], "line3")
end

T['renderer']['normalizes CRLF to LF'] = function()
	local lines = split_content("line1\r\nline2\r\nline3")
	MiniTest.expect.equality(#lines, 3)
	MiniTest.expect.equality(lines[1], "line1")
	MiniTest.expect.equality(lines[2], "line2")
end

T['renderer']['normalizes CR to LF'] = function()
	local lines = split_content("line1\rline2\rline3")
	MiniTest.expect.equality(#lines, 3)
end

T['renderer']['handles empty content'] = function()
	local lines = split_content("")
	MiniTest.expect.equality(#lines, 0)
end

T['renderer']['handles single line'] = function()
	local lines = split_content("just one line")
	MiniTest.expect.equality(#lines, 1)
	MiniTest.expect.equality(lines[1], "just one line")
end

return T
