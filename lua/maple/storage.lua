local M = {}
local json_storage = require('maple.storage.json')

-- Initialize storage backend
local function init_storage()
    return json_storage
end

-- Get the current storage backend
local function get_storage()
    if not M._storage then
        M._storage = init_storage()
    end

    return M._storage
end

-- Forward all function calls to the storage backend
function M.load_todos()
    return get_storage().load_todos()
end

function M.save_todos(todos)
    return get_storage().save_todos(todos)
end

function M.add_todo(text, completed)
    return get_storage().add_todo(text, completed)
end

function M.toggle_todo(id)
    return get_storage().toggle_todo(id)
end

function M.delete_todo(id)
    return get_storage().delete_todo(id)
end

function M.close()
    if M._storage then
        M._storage.close()
    end
end

-- Reset the storage (useful when config changes)
function M.reset()
    if M._storage then
        M._storage.close()
        M._storage = nil
    end
end

return M
