local words = { global = "scope", project = "scope", float = "how", split = "how", vsplit = "how", edit = "how" }

vim.api.nvim_create_user_command("Maple", function(cmd)
	local args = {}
	for _, word in ipairs(cmd.fargs) do
		args[words[word] or word] = word
	end
	require("maple").toggle(args.scope, args.how)
end, {
	nargs = "*",
	complete = function()
		return vim.tbl_keys(words)
	end,
})
