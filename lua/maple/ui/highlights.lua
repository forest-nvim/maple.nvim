local api = vim.api
local config = require("maple.config")

local M = {}

-- Default highlight group definitions (linked to built-in groups)
M.default_links = {
	MapleNormal = "NormalFloat",
	MapleBorder = "FloatBorder",
	MapleTitle = "Title",
	MapleTitleIcon = "Special",
	MapleFooter = "Comment",
	MapleCheckbox = "Keyword",
	MapleCheckboxDone = "Comment",
	MapleTimestamp = "Number",
}

--- Define all highlight groups. User overrides from config take precedence.
function M.setup()
	local user_highlights = config.options.highlights or {}

	for group, link_target in pairs(M.default_links) do
		if user_highlights[group] then
			-- User provided explicit highlight definition
			api.nvim_set_hl(0, group, user_highlights[group])
		else
			-- Use default link
			api.nvim_set_hl(0, group, { link = link_target, default = true })
		end
	end
end

--- Apply winhighlight to a window to use custom maple groups.
function M.apply_to_window(win)
	if not win or not api.nvim_win_is_valid(win) then
		return
	end
	vim.wo[win].winhighlight = "Normal:MapleNormal,FloatBorder:MapleBorder,FloatTitle:MapleTitle"
end

return M
