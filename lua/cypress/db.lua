local M = {}

-- Check if sqlite is available
local has_sqlite, sqlite = pcall(require, 'sqlite')
if not has_sqlite then
    -- Fallback to JSON if SQLite is not available
    vim.notify("SQLite not available. Falling back to JSON storage.", vim.log.levels.WARN)
    return require('maple.storage.json')
end

local config = require('maple.config')
local Path = require('plenary.path')

-- Database connection
local db = nil

-- Initialize the database
local function init_db()
    if db then return db end

    -- Get database path from config
    local db_path = config.options.db_path or vim.fn.stdpath('data') .. '/maple/maple.db'

    -- Ensure parent directory exists
    local db_dir = vim.fn.fnamemodify(db_path, ':h')
    Path:new(db_dir):mkdir({ parents = true })

    -- Connect to the database
    db = sqlite.new(db_path)

    -- Create tables if they don't exist
    db:exec [[
        CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY,
            text TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            project_path TEXT,
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );

        CREATE INDEX IF NOT EXISTS idx_todos_project ON todos(project_path);
    ]]

    return db
end

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

-- Convert todos from DB format to application format
local function db_to_app_format(db_todos)
    local result = {}

    for _, todo in ipairs(db_todos) do
        table.insert(result, {
            id = todo.id,
            text = todo.text,
            completed = todo.completed == 1
        })
    end

    return result
end

-- Convert application format to DB format
local function app_to_db_format(todos, project_path)
    local result = {}

    for _, todo in ipairs(todos) do
        table.insert(result, {
            id = todo.id,
            text = todo.text,
            completed = todo.completed and 1 or 0,
            project_path = project_path,
            updated_at = os.time()
        })
    end

    return result
end

-- Load todos from the database
function M.load_todos()
    local db_conn = init_db()
    local project_path = get_project_path()
    local todos

    if project_path and config.options.todo_mode == "project" then
        -- Load project-specific todos
        todos = db_conn:select('todos', {
            where = {
                project_path = project_path
            },
            order_by = 'created_at'
        })
    elseif config.options.todo_mode == "global" then
        -- Load global todos
        todos = db_conn:select('todos', {
            where = {
                project_path = nil
            },
            order_by = 'created_at'
        })
    else
        -- Load all todos (combined mode)
        todos = db_conn:select('todos', {
            order_by = 'created_at'
        })
    end

    return db_to_app_format(todos or {})
end

-- Save a collection of todos to the database
function M.save_todos(todos)
    local db_conn = init_db()
    local project_path = get_project_path()

    -- Begin transaction
    db_conn:execute('BEGIN TRANSACTION')

    -- Delete existing todos for this project or globally
    if project_path and config.options.todo_mode == "project" then
        db_conn:delete('todos', {
            project_path = project_path
        })
    elseif config.options.todo_mode == "global" then
        db_conn:delete('todos', {
            project_path = nil
        })
    else
        -- In combined mode, delete all todos
        db_conn:delete('todos', {})
    end

    -- Insert new todos
    local db_todos = app_to_db_format(todos, project_path)
    for _, todo in ipairs(db_todos) do
        db_conn:insert('todos', todo)
    end

    -- Commit transaction
    db_conn:execute('COMMIT')
end

-- Add a single todo
function M.add_todo(text, completed)
    local db_conn = init_db()
    local project_path = get_project_path()

    local todo = {
        text = text,
        completed = completed and 1 or 0,
        project_path = project_path,
        created_at = os.time(),
        updated_at = os.time()
    }

    local id = db_conn:insert('todos', todo)
    return id
end

-- Toggle a todo's completion status
function M.toggle_todo(id)
    local db_conn = init_db()

    -- Get current todo
    local todo = db_conn:select('todos', {
        where = { id = id },
        limit = 1
    })[1]

    if todo then
        -- Update the completed status
        db_conn:update('todos', {
            completed = todo.completed == 1 and 0 or 1,
            updated_at = os.time()
        }, {
            id = id
        })
    end
end

-- Delete a todo
function M.delete_todo(id)
    local db_conn = init_db()

    db_conn:delete('todos', {
        id = id
    })
end

-- Close the database connection
function M.close()
    if db then
        db:close()
        db = nil
    end
end

return M
