local M = {}

-- Simple notification wrapper
function M.notify(msg, level)
    vim.schedule(function()
        vim.notify(
            msg,
            vim.log.levels[level:upper()] or vim.log.levels.INFO,
            { title = 'Maple.nvim' }
        )
    end)
end

-- Check if the current buffer is a Maple buffer
function M.is_maple_buf(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return bufname:match('^maple://') ~= nil
end

-- Create an autocommand group
function M.create_augroup(name, autocmds)
    local group = vim.api.nvim_create_augroup('Maple' .. name, { clear = true })
    for _, autocmd in ipairs(autocmds) do
        local event = autocmd.event
        local opts = vim.tbl_extend('force', {
            group = group,
        }, autocmd.opts or {})
        vim.api.nvim_create_autocmd(event, opts)
    end
end

-- Merge two tables recursively
function M.merge_tables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(t1[k]) == 'table' then
            M.merge_tables(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

-- Get the root directory of the current project
function M.get_project_root()
    -- First try to find git root
    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error == 0 then
        return git_root
    end
    
    -- Fall back to current working directory
    return vim.fn.getcwd()
end

-- Check if a file exists
function M.file_exists(path)
    local f = io.open(path, 'r')
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Check if a directory exists
function M.directory_exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
        return false
    end
    return true
end

-- Create a directory if it doesn't exist
function M.ensure_dir(dir_path)
    if not M.directory_exists(dir_path) then
        return os.execute('mkdir -p ' .. vim.fn.shellescape(dir_path)) == 0
    end
    return true
end

-- Get the current time in a formatted string
function M.get_timestamp()
    return os.date('%Y-%m-%d %H:%M:%S')
end

-- Truncate a string to a certain length
function M.truncate(str, max_len, ellipsis)
    if not str then return '' end
    if #str <= max_len then return str end
    return str:sub(1, max_len) .. (ellipsis or '...')
end

-- Create a shallow copy of a table
function M.shallow_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return M
