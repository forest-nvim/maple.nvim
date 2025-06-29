local M = {}
local config = require('maple.config')
local uv = vim.loop
local Path = require('plenary.path')

-- Get the appropriate icon for a file
function M.get_icon(file)
    if file.type == 'directory' then
        return file.is_empty and config.options.icons.folder.empty or config.options.icons.folder.default
    elseif file.type == 'symlink' then
        return config.options.icons.symlink
    end
    return config.options.icons.default
end

-- Check if a directory is empty
function M.is_dir_empty(path)
    local handle = uv.fs_scandir(path)
    if not handle then return true end
    return uv.fs_scandir_next(handle) == nil
end

-- Scan a directory and return its contents
function M.scan_directory(path)
    local files = {}
    local handle = uv.fs_scandir(path)
    
    if not handle then return files end
    
    local name, type
    while true do
        name, type = uv.fs_scandir_next(handle)
        if not name then break end
        
        -- Skip hidden files if configured
        if config.options.hide_dotfiles and name:sub(1, 1) == '.' then
            goto continue
        end
        
        local full_path = Path:new(path, name):absolute()
        local is_dir = type == 'directory'
        local is_empty = is_dir and M.is_dir_empty(full_path)
        local file_type = type or 'file'  -- Default to 'file' if type is nil
        
        table.insert(files, {
            name = name,
            path = full_path,
            type = file_type,
            is_dir = is_dir,
            is_empty = is_empty,
            extension = name:match('%.([^%.]+)$') or ''
        })
        
        ::continue::
    end
    
    -- Sort directories first, then files, both alphabetically
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

-- Create a new file
function M.create_file(path, name)
    local file_path = Path:new(path, name)
    
    -- Ensure the directory exists
    file_path:parent():mkdir({parents = true})
    
    -- Create the file
    local fd = uv.fs_open(file_path.filename, 'w', 420) -- 420 = 0644 in decimal
    if not fd then
        return false, 'Failed to create file: ' .. file_path.filename
    end
    uv.fs_close(fd)
    
    return true, file_path.filename
end

-- Create a new directory
function M.create_directory(path, name)
    local dir_path = Path:new(path, name)
    local success, err = pcall(dir_path.mkdir, dir_path, {parents = true})
    
    if not success then
        return false, 'Failed to create directory: ' .. err
    end
    
    return true, dir_path.filename
end

-- Rename a file or directory
function M.rename(old_path, new_path)
    local success, err = pcall(Path.rename, Path:new(old_path), Path:new(new_path))
    if not success then
        return false, 'Failed to rename: ' .. err
    end
    return true, new_path
end

-- Delete a file or directory
function M.delete(path, recursive)
    local path_obj = Path:new(path)
    
    if path_obj:is_dir() then
        if recursive then
            local success, err = pcall(path_obj.rm, path_obj, {recursive = true})
            if not success then
                return false, 'Failed to delete directory: ' .. err
            end
        else
            -- Only delete empty directories
            if M.is_dir_empty(path) then
                local success, err = pcall(path_obj.rmdir, path_obj)
                if not success then
                    return false, 'Failed to delete directory: ' .. err
                end
            else
                return false, 'Directory is not empty'
            end
        end
    else
        -- It's a file
        local success, err = pcall(path_obj.rm, path_obj)
        if not success then
            return false, 'Failed to delete file: ' .. err
        end
    end
    
    return true
end

return M
