local M = {}
local api = vim.api
local config = require('maple.config')
local utils = require('maple.utils')
local fs = require('maple.fs')

local ns_id = api.nvim_create_namespace('maple')
local buf, win
local is_open = false

-- Create the panel buffer
local function create_buf()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(buf, 'maple://panel')
    api.nvim_buf_set_option(buf, 'filetype', 'maple')
    api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    api.nvim_buf_set_option(buf, 'swapfile', false)
    api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    api.nvim_buf_set_option(buf, 'modifiable', false)
    api.nvim_buf_set_option(buf, 'readonly', true)
    return buf
end

-- Create the panel window
local function create_win()
    local width = config.options.width
    local position = config.options.position
    
    local opts = {
        relative = 'editor',
        width = width,
        height = vim.o.lines - vim.o.cmdheight - 1,
        row = 0,
        col = position == 'left' and 0 or (vim.o.columns - width - 1),
        style = 'minimal',
        border = 'single',
        title = ' Notes ',
        title_pos = 'center',
    }
    
    win = api.nvim_open_win(buf, true, opts)
    
    -- Configure window options
    api.nvim_win_set_option(win, 'number', false)
    api.nvim_win_set_option(win, 'relativenumber', false)
    api.nvim_win_set_option(win, 'wrap', false)
    
    -- Set up keymaps
    local keymaps = config.options.keymaps
    for action, key in pairs(keymaps) do
        if action ~= 'toggle' then
            api.nvim_buf_set_keymap(buf, 'n', key, '', {
                noremap = true,
                silent = true,
                callback = function()
                    M[action](M)
                end,
                desc = 'Maple: ' .. action:gsub('_', ' ')
            })
        end
    end
    
    -- Add help keymap
    api.nvim_buf_set_keymap(buf, 'n', '?', '', {
        noremap = true,
        silent = true,
        callback = M.show_help,
        desc = 'Maple: Show help'
    })
    
    -- Add default keymap for opening files
    api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = M.open_file,
        desc = 'Maple: Open file/folder'
    })
    
    return win
end

-- Close the panel window
function M.close()
    if win and api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
    end
    is_open = false
    win = nil
end

-- Toggle the panel
function M.toggle()
    if is_open then
        M.close()
    else
        M.open()
    end
end

-- Open the panel
function M.open()
    if not is_open then
        create_buf()
        create_win()
        M.refresh()
        is_open = true
    end
end

-- Focus the panel
function M.focus()
    if not is_open then
        M.open()
    end
    if win and api.nvim_win_is_valid(win) then
        api.nvim_set_current_win(win)
    end
end

-- Refresh the panel content
function M.refresh()
    if not buf or not api.nvim_buf_is_valid(buf) then return end
    
    -- Get the notes directory from config
    local notes_dir = config.options.notes_dir
    
    -- Create notes directory if it doesn't exist
    if not vim.fn.isdirectory(notes_dir) then
        vim.fn.mkdir(notes_dir, 'p')
    end
    
    -- List directory contents
    local files = fs.scan_directory(notes_dir)
    
    -- Format files for display
    local lines = {}
    for _, file in ipairs(files) do
        local icon = fs.get_icon(file)
        table.insert(lines, icon .. ' ' .. file.name)
    end
    
    -- Update buffer
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Create a new file
function M.create_file()
    -- TODO: Implement file creation
    utils.notify('Create file functionality coming soon!', 'info')
end

-- Create a new folder
function M.create_folder()
    -- TODO: Implement folder creation
    utils.notify('Create folder functionality coming soon!', 'info')
end

-- Rename a file or folder
function M.rename()
    -- TODO: Implement rename
    utils.notify('Rename functionality coming soon!', 'info')
end

-- Delete a file or folder
function M.delete()
    -- TODO: Implement delete
    utils.notify('Delete functionality coming soon!', 'warning')
end

-- Open a file or folder
function M.open_file()
    -- TODO: Implement file opening
    utils.notify('Open file functionality coming soon!', 'info')
end

-- Show help
function M.show_help()
    local help_lines = {
        'Maple.nvim Help',
        '================',
        '<CR> - Open file/folder',
        'a - Create new file',
        'd - Create new directory',
        'r - Rename file/directory',
        'D - Delete file/directory',
        'R - Refresh the file tree',
        'q - Close the panel',
        '? - Show this help',
    }
    
    -- Create a floating window to display help
    local width = 40
    local height = #help_lines + 2
    local row = (vim.o.lines - height) / 2
    local col = (vim.o.columns - width) / 2
    
    local help_buf = api.nvim_create_buf(false, true)
    local help_win = api.nvim_open_win(help_buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'single',
        title = ' Maple Help ',
        title_pos = 'center',
    })
    
    api.nvim_buf_set_lines(help_buf, 0, -1, false, help_lines)
    api.nvim_buf_set_option(help_buf, 'modifiable', false)
    
    -- Close help window when pressing q or <Esc>
    api.nvim_buf_set_keymap(help_buf, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
    api.nvim_buf_set_keymap(help_buf, 'n', '<Esc>', '<cmd>close<CR>', {noremap = true, silent = true})
    
    -- Return focus to the panel
    vim.schedule(function()
        if win and api.nvim_win_is_valid(win) then
            api.nvim_set_current_win(win)
        end
    end)
end

return M
