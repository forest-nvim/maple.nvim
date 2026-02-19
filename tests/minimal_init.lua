-- Minimal init for running tests
local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(plugin_root)

-- Locate or download mini.nvim for mini.test
local mini_path = plugin_root .. "/deps/mini.nvim"
if not (vim.uv or vim.loop).fs_stat(mini_path) then
	vim.fn.mkdir(plugin_root .. "/deps", "p")
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	})
end
vim.opt.runtimepath:prepend(mini_path)

vim.opt.swapfile = false
vim.opt.shadafile = "NONE"
