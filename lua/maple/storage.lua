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
function M.load_notes()
    return get_storage().load_notes()
end

function M.save_notes(content)
    return get_storage().save_notes(content)
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
