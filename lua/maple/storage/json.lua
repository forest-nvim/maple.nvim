local M = {}
local config = require('maple.config')
local Path = require('plenary.path')
local uv = vim.loop

-- Store notes in memory
local notes = {}
local file_locks = {}

-- Get the current project path
local function get_project_path()
    if config.options.use_project_specific_notes then
        -- Try to get git root
        local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
        if git_root ~= "" then
            return git_root
        end

        -- Fallback to current working directory
        return vim.fn.getcwd()
    end

    -- Return nil for global notes
    return nil
end

-- Get the path for storing notes
local function get_storage_path(is_global)
    local base_path = config.options.storage_path or vim.fn.stdpath('data') .. '/maple'

    -- Create the directory if it doesn't exist
    Path:new(base_path):mkdir({ parents = true })

    -- Determine storage file based on mode
    if not is_global and config.options.use_project_specific_notes then
        -- Project-specific notes
        local project_path = get_project_path()
        if project_path then
            -- Create a hash of the project path for the filename
            local hash = vim.fn.sha256(project_path)
            return base_path .. '/project-' .. string.sub(hash, 1, 10) .. '.json'
        end
    end
    -- Global notes
    return base_path .. '/global.json'
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

local function safe_json_decode(content)
    local success, result = pcall(vim.json.decode, content)
    if not success then
        vim.notify("Failed to parse JSON: " .. tostring(result), vim.log.levels.ERROR)
        return { content = "" }
    end
    return result
end

local function safe_json_encode(data)
    local success, result = pcall(vim.json.encode, data)
    if not success then
        vim.notify("Failed to encode JSON: " .. tostring(result), vim.log.levels.ERROR)
        return "{\"content\":\"\"}"
    end
    return result
end

-- Load notes from file if it exists
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
            local notes_data = safe_json_decode(content)
            if notes_data and notes_data.content then
                result = notes_data
            end
        end
    end

    release_lock(file_path)
    return result
end

-- Save notes to file
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

    local success, f = pcall(io.open, file_path, 'w')
    if success and f then
        f:write(safe_json_encode(notes_content))
        f:close()
        notes = notes_content
    else
        vim.notify("Failed to save notes to file", vim.log.levels.ERROR)
    end

    release_lock(file_path)
end

function M.cleanup_old_files()
    local base_path = config.options.storage_path or vim.fn.stdpath('data') .. '/maple'
    local files = vim.fn.glob(base_path .. '/project-*.json', true, true)
    local current_time = os.time()
    local max_age = 30 * 24 * 60 * 60 -- 30 days in seconds

    for _, file in ipairs(files) do
        local stat = uv.fs_stat(file)
        if stat and (current_time - stat.mtime.sec) > max_age then
            os.remove(file)
        end
    end
end

-- Close function for storage API consistency
function M.close()
    M.cleanup_old_files()
end

return M
