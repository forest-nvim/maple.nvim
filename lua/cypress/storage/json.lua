local M = {}
local config = require('maple.config')
local Path = require('plenary.path')

-- Store todos in memory
local todos = {}

-- Get the path for storing todos
local function get_storage_path()
    local base_path = config.options.storage_path or vim.fn.stdpath('data') .. '/maple'

    -- Create the directory if it doesn't exist
    Path:new(base_path):mkdir({ parents = true })

    -- Determine storage file based on mode
    if config.options.todo_mode == "project" and config.options.use_project_specific_todos then
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

-- Load todos from file if it exists
function M.load_todos()
    local todo_file = get_storage_path()
    local f = io.open(todo_file, 'r')
    if f then
        local content = f:read('*all')
        f:close()
        if content and content ~= '' then
            todos = vim.json.decode(content)

            -- Convert todos to the expected format if needed
            local result = {}
            for i, todo in ipairs(todos) do
                -- If todo is just a string from older versions, convert it
                if type(todo) == "string" then
                    todo = { text = todo, completed = false }
                end

                -- Ensure ID exists
                if not todo.id then
                    todo.id = i
                end

                table.insert(result, todo)
            end

            return result
        end
    end

    return {}
end

-- Save todos to file
function M.save_todos(todos_to_save)
    local todo_file = get_storage_path()
    local f = io.open(todo_file, 'w')
    if f then
        f:write(vim.json.encode(todos_to_save))
        f:close()
    end

    -- Update in-memory cache
    todos = todos_to_save
end

-- Add a single todo
function M.add_todo(text, completed)
    local todos = M.load_todos()

    -- Find the highest ID
    local max_id = 0
    for _, todo in ipairs(todos) do
        if todo.id and todo.id > max_id then
            max_id = todo.id
        end
    end

    -- Create a new todo with the next ID
    local new_id = max_id + 1
    local new_todo = {
        id = new_id,
        text = text,
        completed = completed or false
    }

    -- Add to todos and save
    table.insert(todos, new_todo)
    M.save_todos(todos)

    return new_id
end

-- Toggle a todo's completion status
function M.toggle_todo(id)
    local todos = M.load_todos()

    for i, todo in ipairs(todos) do
        if todo.id == id then
            todo.completed = not todo.completed
            M.save_todos(todos)
            break
        end
    end
end

-- Delete a todo
function M.delete_todo(id)
    local todos = M.load_todos()

    for i, todo in ipairs(todos) do
        if todo.id == id then
            table.remove(todos, i)
            M.save_todos(todos)
            break
        end
    end
end

-- No-op function to match API with sqlite
function M.close()
    -- Nothing needed for JSON storage
end

return M
