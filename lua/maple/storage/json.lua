local M = {}
local config = require('maple.config')
local Path = require('plenary.path')
local uv = vim.loop

-- Store todos in memory
local todos = {}
local file_locks = {}

-- Get the current project path
local function get_project_path()
    if config.options.use_project_specific_todos then
        -- Try to get git root
        local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
        if git_root ~= "" then
            return git_root
        end

        -- Fallback to current working directory
        return vim.fn.getcwd()
    end

    -- Return nil for global todos
    return nil
end

-- Get the path for storing todos
local function get_storage_path(is_global)
    local base_path = config.options.storage_path or vim.fn.stdpath('data') .. '/maple'

    -- Create the directory if it doesn't exist
    Path:new(base_path):mkdir({ parents = true })

    -- Determine storage file based on mode
    if not is_global and config.options.use_project_specific_todos then
        -- Project-specific todos
        local project_path = get_project_path()
        if project_path then
            -- Create a hash of the project path for the filename
            local hash = vim.fn.sha256(project_path)
            return base_path .. '/project-' .. string.sub(hash, 1, 10) .. '.json'
        end
    end
    -- Global todos
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
        return {}
    end
    return result
end

local function safe_json_encode(data)
    local success, result = pcall(vim.json.encode, data)
    if not success then
        vim.notify("Failed to encode JSON: " .. tostring(result), vim.log.levels.ERROR)
        return "[]"
    end
    return result
end

-- Load todos from file if it exists
function M.load_todos()
    local project_path = get_project_path()
    local result = {}
    local file_path = get_storage_path(config.options.todo_mode == "global")

    if not acquire_lock(file_path) then
        vim.notify("Failed to acquire lock for file: " .. file_path, vim.log.levels.WARN)
        return result
    end

    local success, f = pcall(io.open, file_path, 'r')
    if success and f then
        local content = f:read('*all')
        f:close()
        if content and content ~= '' then
            local todos_data = safe_json_decode(content)
            for _, todo in ipairs(todos_data) do
                if type(todo) == "string" then
                    todo = { text = todo, completed = false, is_global = config.options.todo_mode == "global" }
                end
                if not todo.id then
                    todo.id = #result + 1
                end
                todo.is_global = config.options.todo_mode == "global"
                table.insert(result, todo)
            end
        end
    end

    release_lock(file_path)
    return result
end

-- Save todos to file
function M.save_todos(todos_to_save)
    if not todos_to_save or type(todos_to_save) ~= "table" then
        vim.notify("Invalid todos data provided", vim.log.levels.ERROR)
        return
    end

    local project_path = get_project_path()
    local global_todos = {}
    local project_todos = {}

    -- Separate global and project todos
    for _, todo in ipairs(todos_to_save) do
        if todo.is_global then
            table.insert(global_todos, todo)
        else
            table.insert(project_todos, todo)
        end
    end

    local file_path = get_storage_path(config.options.todo_mode == "global")
    if not acquire_lock(file_path) then
        vim.notify("Failed to acquire lock for file: " .. file_path, vim.log.levels.WARN)
        return
    end

    local success, f = pcall(io.open, file_path, 'w')
    if success and f then
        local data = config.options.todo_mode == "global" and global_todos or project_todos
        f:write(safe_json_encode(data))
        f:close()
        todos = todos_to_save
    else
        vim.notify("Failed to save todos to file", vim.log.levels.ERROR)
    end

    release_lock(file_path)
end

-- Add a single todo
function M.add_todo(text, completed)
    if not text or type(text) ~= "string" or text:len() == 0 then
        vim.notify("Invalid todo text provided", vim.log.levels.ERROR)
        return nil
    end

    local todos = M.load_todos()
    local max_id = 0
    for _, todo in ipairs(todos) do
        if todo.id and todo.id > max_id then
            max_id = todo.id
        end
    end

    local new_id = max_id + 1
    local new_todo = {
        id = new_id,
        text = text,
        completed = completed or false,
        is_global = config.options.todo_mode == "global",
        created_at = os.time()
    }

    table.insert(todos, new_todo)
    M.save_todos(todos)

    return new_id
end

-- Toggle a todo's completion status
function M.toggle_todo(id)
    if not id or type(id) ~= "number" then
        vim.notify("Invalid todo ID provided", vim.log.levels.ERROR)
        return
    end

    local todos = M.load_todos()
    local found = false

    for _, todo in ipairs(todos) do
        if todo.id == id then
            todo.completed = not todo.completed
            todo.updated_at = os.time()
            found = true
            break
        end
    end

    if found then
        M.save_todos(todos)
    else
        vim.notify("Todo with ID " .. id .. " not found", vim.log.levels.WARN)
    end
end

-- Delete a todo
function M.delete_todo(id)
    if not id or type(id) ~= "number" then
        vim.notify("Invalid todo ID provided", vim.log.levels.ERROR)
        return
    end

    local todos = M.load_todos()
    local found = false

    for i, todo in ipairs(todos) do
        if todo.id == id then
            table.remove(todos, i)
            found = true
            break
        end
    end

    if found then
        M.save_todos(todos)
    else
        vim.notify("Todo with ID " .. id .. " not found", vim.log.levels.WARN)
    end
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
