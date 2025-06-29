local M = {}
local config = require('maple.config')

function M.scan_dir(path)
    local files = {}
    local handle = vim.loop.fs_scandir(path)

    if not handle then
        return files
    end

    local name, type = vim.loop.fs_scandir_next(handle)
    while name do
        if name ~= '.' and name ~= '..' then
            local full_path = path .. '/' .. name
            local is_dir = type == 'directory'

            table.insert(files, {
                name = name,
                path = full_path,
                is_dir = is_dir,
                icon = is_dir and config.icons.folder or config.icons.file
            })
        end

        name, type = vim.loop.fs_scandir_next(handle)
    end

    table.sort(files, function(a, b)
        if a.is_dir and not b.is_dir then
            return true
        elseif not a.is_dir and b.is_dir then
            return false
        else
            return a.name:lower() < b.name:lower()
        end
    end)

    return files
end

function M.create_file(dir, name)
    if not dir or not name then
        return false
    end

    local path = dir .. '/' .. name
    local file = io.open(path, 'w')
    if file then
        file:close()
        return true
    end
    return false
end

function M.create_dir(dir, name)
    if not dir or not name then
        return false
    end

    local path = dir .. '/' .. name
    return vim.fn.mkdir(path, 'p') == 1
end

function M.delete_path(path)
    if not path or path == '' then
        return false
    end

    if vim.fn.isdirectory(path) == 1 then
        return vim.fn.delete(path, 'rf') == 0
    else
        return vim.fn.delete(path) == 0
    end
end

function M.exists(path)
    return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

function M.is_dir(path)
    return vim.fn.isdirectory(path) == 1
end

function M.basename(path)
    return vim.fn.fnamemodify(path, ':t')
end

function M.dirname(path)
    return vim.fn.fnamemodify(path, ':h')
end

return M
