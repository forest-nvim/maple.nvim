local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality

local dir = vim.fn.tempname()
local maple = require("maple")
maple.setup({
	dir = dir,
	root = function()
		return "/proj/foo"
	end,
})

-- Notes currently shown in a window, relative to dir.
local function shown()
	local names = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
		if vim.startswith(name, dir) then
			names[#names + 1] = name:sub(#dir + 2)
		end
	end
	return names
end

local T = MiniTest.new_set({
	hooks = {
		post_case = function()
			maple.close()
			vim.cmd("silent! %bwipeout!")
		end,
	},
})

T["notes mirror the project path"] = function()
	eq(maple.path("global"), dir .. "/global.md")
	eq(maple.path(), dir .. "/proj/foo.md")
end

T[":Maple opens, swaps and closes"] = function()
	vim.cmd("Maple")
	eq(shown(), { "proj/foo.md" })
	eq(vim.api.nvim_win_get_config(0).relative, "editor")
	eq(vim.bo.filetype, "markdown")
	vim.cmd("Maple split global")
	eq(shown(), { "global.md" })
	eq(vim.api.nvim_win_get_config(0).relative, "")
	vim.cmd("Maple global")
	eq(shown(), {})
end

T["notes are written on close and on leaving the buffer"] = function()
	maple.toggle("global")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello" })
	maple.toggle("global")
	eq(vim.fn.readfile(dir .. "/global.md"), { "hello" })
	maple.open("global", "split")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello", "world" })
	vim.cmd("wincmd p")
	eq(vim.fn.readfile(dir .. "/global.md"), { "hello", "world" })
end

return T
