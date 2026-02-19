local M = {}
local config = require('maple.config')

local file_locks = {}

local function get_project_path()
	if config.options.use_project_specific_notes then
		local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
		if git_root ~= "" then
			return git_root
		end
		return vim.fn.getcwd()
	end
	return nil
end

local function get_base_path()
	local base_path = config.options.storage_path or vim.fn.stdpath('data') .. '/maple'
	vim.fn.mkdir(base_path, "p")
	return base_path
end

local function update_project_map(base_path, hash, project_path)
	local map_path = base_path .. '/.projects.json'
	local map = {}
	local f = io.open(map_path, 'r')
	if f then
		local raw = f:read('*all')
		f:close()
		if raw and raw ~= '' then
			local ok, decoded = pcall(vim.json.decode, raw)
			if ok and type(decoded) == "table" then
				map = decoded
			end
		end
	end

	local name = vim.fn.fnamemodify(project_path, ':t')
	if map[hash] ~= name then
		map[hash] = name
		f = io.open(map_path, 'w')
		if f then
			f:write(vim.json.encode(map))
			f:close()
		end
	end
end

local function get_storage_path(is_global)
	local base_path = get_base_path()

	if not is_global and config.options.use_project_specific_notes then
		local project_path = get_project_path()
		if project_path then
			local hash = string.sub(vim.fn.sha256(project_path), 1, 10)
			update_project_map(base_path, hash, project_path)
			return base_path .. '/project-' .. hash .. '.md'
		end
	end
	return base_path .. '/global.md'
end

local function acquire_lock(file_path)
	if file_locks[file_path] then
		return false
	end
	file_locks[file_path] = true
	return true
end

local function release_lock(file_path)
	file_locks[file_path] = nil
end

function M.load_notes()
	local file_path = get_storage_path(config.options.notes_mode == "global")
	local result = { content = "" }

	if not acquire_lock(file_path) then
		vim.notify("Failed to acquire lock for file: " .. file_path, vim.log.levels.WARN)
		return result
	end

	local success, f = pcall(io.open, file_path, 'r')
	if success and f then
		local content = f:read('*all')
		f:close()
		if content and content ~= '' then
			result.content = content
		end
	end

	release_lock(file_path)
	return result
end

function M.save_notes(notes_content)
	if not notes_content then
		vim.notify("Invalid notes data provided", vim.log.levels.ERROR)
		return
	end

	local file_path = get_storage_path(config.options.notes_mode == "global")
	if not acquire_lock(file_path) then
		vim.notify("Failed to acquire lock for file: " .. file_path, vim.log.levels.WARN)
		return
	end

	local content = ""
	if type(notes_content) == "table" then
		content = notes_content.content or ""
	elseif type(notes_content) == "string" then
		content = notes_content
	end

	local success, f = pcall(io.open, file_path, 'w')
	if success and f then
		f:write(content)
		f:close()
	else
		vim.notify("Failed to save notes to file", vim.log.levels.ERROR)
	end

	release_lock(file_path)
end

function M.get_project_map()
	local base_path = get_base_path()
	local map_path = base_path .. '/.projects.json'
	local f = io.open(map_path, 'r')
	if not f then
		return {}
	end
	local raw = f:read('*all')
	f:close()
	if not raw or raw == '' then
		return {}
	end
	local ok, decoded = pcall(vim.json.decode, raw)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return {}
end

function M.reset()
end

return M
