-- Telescope extension for maple.nvim
-- Usage:
--   require('telescope').load_extension('maple')
--   :Telescope maple         -- list all note files
--   :Telescope maple grep    -- live grep across note contents

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("telescope.nvim is required for the maple telescope extension")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local config = require("maple.config")
local storage = require("maple.storage")

local function read_note_file(file_path)
	local f = io.open(file_path, "r")
	if not f then
		return nil
	end
	local raw = f:read("*all")
	f:close()
	if not raw or raw == "" then
		return nil
	end
	return raw
end

local function note_label(filename, project_map)
	if filename:match("^global%.") then
		return "Global Notes", "global"
	end
	local hash = filename:match("^project%-(.+)%.[^.]+$")
	if hash then
		local name = project_map[hash]
		if name then
			return name, "project"
		end
		return "Project " .. hash, "project"
	end
	return filename, "unknown"
end

local function collect_notes()
	local base_path = config.options.storage_path or (vim.fn.stdpath("data") .. "/maple")
	local entries = {}
	local uv = vim.uv or vim.loop
	local project_map = storage.get_project_map()

	local files = vim.fn.glob(base_path .. "/*.md", true, true)
	for _, file_path in ipairs(files) do
		local filename = vim.fn.fnamemodify(file_path, ":t")
		local label, scope = note_label(filename, project_map)
		local stat = uv.fs_stat(file_path)
		local mtime = stat and stat.mtime and stat.mtime.sec or 0
		local content = read_note_file(file_path)

		if content then
			table.insert(entries, {
				path = file_path,
				filename = filename,
				label = label,
				scope = scope,
				mtime = mtime,
				content = content,
			})
		end
	end

	table.sort(entries, function(a, b)
		return a.mtime > b.mtime
	end)
	return entries
end

local function format_date(timestamp)
	if timestamp == 0 then
		return "unknown"
	end
	return os.date("%Y-%m-%d %H:%M", timestamp)
end

-- Note finder picker
local function note_finder_picker(opts)
	opts = opts or {}
	local entries = collect_notes()
	if #entries == 0 then
		vim.notify("Maple: no notes found", vim.log.levels.INFO)
		return
	end

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 24 },
			{ width = 8 },
			{ width = 16 },
			{ remaining = true },
		},
	})

	pickers
		.new(opts, {
			prompt_title = "Maple Notes",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(note_entry)
					return {
						value = note_entry,
						display = function(entry)
							local snippet = entry.value.content or ""
							for line in snippet:gmatch("[^\r\n]+") do
								local trimmed = line:match("^%s*(.-)%s*$")
								if trimmed and trimmed ~= "" then
									snippet = trimmed
									break
								end
							end
							if #snippet > 60 then
								snippet = snippet:sub(1, 57) .. "..."
							end
							return displayer({
								{ entry.value.label, "TelescopeResultsIdentifier" },
								{ entry.value.scope, "TelescopeResultsComment" },
								{ format_date(entry.value.mtime), "TelescopeResultsNumber" },
								{ snippet, "TelescopeResultsComment" },
							})
						end,
						ordinal = note_entry.label
							.. " "
							.. note_entry.scope
							.. " "
							.. (note_entry.content or ""),
						path = note_entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Note Content",
				define_preview = function(self, entry)
					local content = entry.value.content or ""
					local lines = {}
					for line in (content .. "\n"):gmatch("(.-)\n") do
						table.insert(lines, line)
					end
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
				end,
			}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected(prompt_bufnr)
					actions.close(prompt_bufnr)
					if selection and selection.value then
						if selection.value.scope == "global" then
							config.options.notes_mode = "global"
						else
							config.options.notes_mode = "project"
						end
						local storage = require("maple.storage")
						storage.reset()
						require("maple").toggle()
					end
				end)
				return true
			end,
		})
		:find()
end

-- Note content grep picker
local function note_grep_picker(opts)
	opts = opts or {}
	local entries = collect_notes()
	if #entries == 0 then
		vim.notify("Maple: no notes found", vim.log.levels.INFO)
		return
	end

	local all_lines = {}
	for _, note_entry in ipairs(entries) do
		local lnum = 0
		for line in ((note_entry.content or "") .. "\n"):gmatch("(.-)\n") do
			lnum = lnum + 1
			table.insert(all_lines, {
				text = line,
				lnum = lnum,
				note = note_entry,
			})
		end
	end

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 20 },
			{ width = 5 },
			{ remaining = true },
		},
	})

	pickers
		.new(opts, {
			prompt_title = "Maple Notes Grep",
			finder = finders.new_table({
				results = all_lines,
				entry_maker = function(line_entry)
					return {
						value = line_entry,
						display = function(entry)
							return displayer({
								{ entry.value.note.label, "TelescopeResultsIdentifier" },
								{ tostring(entry.value.lnum), "TelescopeResultsLineNr" },
								{ entry.value.text, "TelescopeResultsComment" },
							})
						end,
						ordinal = line_entry.text,
						path = line_entry.note.path,
						lnum = line_entry.lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Note Content",
				define_preview = function(self, entry)
					local content = entry.value.note.content or ""
					local lines = {}
					for line in (content .. "\n"):gmatch("(.-)\n") do
						table.insert(lines, line)
					end
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
					local hl_lnum = entry.value.lnum - 1
					if hl_lnum >= 0 and hl_lnum < #lines then
						vim.api.nvim_buf_add_highlight(self.state.bufnr, 0, "TelescopePreviewLine", hl_lnum, 0, -1)
					end
				end,
			}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected(prompt_bufnr)
					actions.close(prompt_bufnr)
					if selection and selection.value then
						if selection.value.note.scope == "global" then
							config.options.notes_mode = "global"
						else
							config.options.notes_mode = "project"
						end
						local storage = require("maple.storage")
						storage.reset()
						require("maple").toggle()
					end
				end)
				return true
			end,
		})
		:find()
end

return telescope.register_extension({
	exports = {
		maple = note_finder_picker,
		grep = note_grep_picker,
	},
})
