local api = vim.api
local window = require('maple.ui.window')
local config = require('maple.config')

local M = {}
local footer_ns_id = nil
local footer_extmark_id = nil

-- Initialize namespace for extmarks
local function ensure_namespace()
    if not footer_ns_id then
        footer_ns_id = api.nvim_create_namespace('maple_footer')
    end
    return footer_ns_id
end

function M.render_notes(notes_data)
    local buf = window.get_buf()
    local win = window.get_win()

    -- Ensure namespace is created
    ensure_namespace()

    -- Clear any existing extmarks
    if footer_extmark_id then
        pcall(api.nvim_buf_del_extmark, buf, footer_ns_id, footer_extmark_id)
        footer_extmark_id = nil
    end

    local lines = {}
    local content = notes_data.content or ""

	-- Split content into lines
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

    -- Create footer text
    local mode_text = ""
    if config.options.notes_mode == "global" then
        mode_text = "Global Notes"
    else
        mode_text = "Project Notes"
    end

    -- Update window title
    window.update_title()

    local footer_text = ""
    
    -- Only show legend if enabled in config
    if config.options.show_legend ~= false then
        local legend_items = {
            string.format("[%s] Switch Mode", 'm'),
            string.format("[%s] Close", 'q')
        }
        footer_text = "  " .. table.concat(legend_items, "  ") .. "\n"
    end
    
    footer_text = footer_text .. string.format("  Mode: %s", mode_text)

    -- Fill the buffer with the content
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Get the last line index
    local last_line = math.max(0, api.nvim_buf_line_count(buf) - 1)

    -- Set the window for editing
    if win and api.nvim_win_is_valid(win) then
        -- Setup scrolloff to ensure footer is always visible
        api.nvim_win_set_option(win, 'scrolloff', 3)
    end
end

-- Get content from the buffer as a single string
function M.get_notes_content()
    local buf = window.get_buf()
    local win = window.get_win()

    if not api.nvim_win_is_valid(win) then
        return ""
    end

    -- Get all lines from the buffer - no need to handle footer as it's virtual
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Remove trailing empty lines
    while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
    end

    return table.concat(lines, "\n")
end

return M
