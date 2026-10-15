local M = {}

M.config = {
	dir = vim.fn.stdpath("data") .. "/maple",
	root = function()
		return vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
	end,
	-- just fractions of the editor height and width, rounded down
	float = { width = 0.6, height = 0.6, border = "rounded" },
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- ~/code/maple.nvim -> <dir>/home/aiden/code/maple.nvim.md
-- might be worth just removing the home/aiden but i think
-- some users might have multiple users on their pc, for example
-- separating work and personal projects. also for work in root folders
function M.path(scope)
	if scope == "global" then
		return M.config.dir .. "/global.md"
	end
	return M.config.dir .. M.config.root() .. ".md"
end

-- a window showing path, or any window showing a note when path is nil
local function find_win(path)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
		if name == path or (not path and vim.startswith(name, M.config.dir)) then
			return win
		end
	end
end

function M.open(scope, how)
	local path = M.path(scope)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	if how and how ~= "float" then
		return vim.cmd[how](vim.fn.fnameescape(path)) -- split | vsplit | edit
	end
	local f = M.config.float
	local w, h = math.floor(vim.o.columns * f.width), math.floor(vim.o.lines * f.height)
	vim.api.nvim_open_win(
		vim.fn.bufadd(path),
		true,
		vim.tbl_extend("force", f, {
			relative = "editor",
			width = w,
			height = h,
			row = math.floor((vim.o.lines - h) / 2),
			col = math.floor((vim.o.columns - w) / 2),
		})
	)
	vim.keymap.set("n", "q", M.close, { buffer = true })
end

function M.close()
	local win = find_win()
	if not win then
		return
	end
	vim.api.nvim_win_call(win, function()
		vim.cmd("silent! update")
	end)
	pcall(vim.api.nvim_win_close, win, true)
end

-- Same note open -> close it
-- Other note open -> swap to this one.
-- Nothing open -> open
function M.toggle(scope, how)
	if find_win(M.path(scope)) then
		return M.close()
	end
	M.close()
	M.open(scope, how)
end

-- if the user just closes it, save preclose
vim.api.nvim_create_autocmd("BufLeave", {
	group = vim.api.nvim_create_augroup("maple", {}),
	callback = function(ev)
		if vim.startswith(vim.api.nvim_buf_get_name(ev.buf), M.config.dir) then
			vim.cmd("silent! update")
		end
	end,
})

return M
