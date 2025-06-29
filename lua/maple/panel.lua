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
    
    -- Save current window to return to it later
    local current_win = api.nvim_get_current_win()
    
    -- Create a new vertical split
    vim.cmd('vsplit')
    win = api.nvim_get_current_win()
    
    -- Set window width
    vim.cmd('vertical resize ' .. width)
    
    -- Set the buffer in the window
    api.nvim_win_set_buf(win, buf)
    
    -- Configure window options
    api.nvim_win_set_option(win, 'number', false)
    api.nvim_win_set_option(win, 'relativenumber', false)
    api.nvim_win_set_option(win, 'wrap', false)
    api.nvim_win_set_option(win, 'winfixwidth', true)  -- Keep width when closing other splits
    api.nvim_win_set_option(win, 'signcolumn', 'no')   -- Disable sign column for better performance
    api.nvim_win_set_option(win, 'cursorline', false)  -- Disable cursor line for better performance
    
    -- Only set up keymaps if they haven't been set up yet
    if not vim.b._maple_keymaps_set then
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
        
        vim.b._maple_keymaps_set = true
    end
    
    -- Return to the original window
    api.nvim_set_current_win(current_win)
    
    return win
end

-- Close the panel window
function M.close()
    if win and api.nvim_win_is_valid(win) then
        local current_win = api.nvim_get_current_win()
        if current_win == win then
            -- If we're in the panel window, go to the next window before closing
            vim.cmd('wincmd p')
        end
        api.nvim_win_close(win, true)
        
        -- Clear the buffer if it exists
        if buf and api.nvim_buf_is_valid(buf) then
            api.nvim_buf_delete(buf, { force = true })
        end
    end
    is_open = false
    win = nil
    buf = nil
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
    -- If panel is already open, just focus it
    if is_open and win and api.nvim_win_is_valid(win) then
        api.nvim_set_current_win(win)
        return
    end
    
    -- Create new buffer if needed
    if not buf or not api.nvim_buf_is_valid(buf) then
        buf = create_buf()
    end
    
    -- Create window if needed
    if not win or not api.nvim_win_is_valid(win) then
        create_win()
    end
    
    -- Refresh content and set focus
    M.refresh()
    is_open = true
    api.nvim_set_current_win(win)
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
    
    -- Get the current working directory
    local cwd = vim.fn.getcwd()
    local notes_dir = cwd .. '/.maple'
    
    -- Create .maple directory if it doesn't exist
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
    
    -- Only update if content has changed
    local current_lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    local current_content = table.concat(current_lines, '\n')
    local new_content = table.concat(lines, '\n')
    
    if current_content ~= new_content then
        -- Update buffer
        api.nvim_buf_set_option(buf, 'modifiable', true)
        api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        api.nvim_buf_set_option(buf, 'modifiable', false)
    end
end

-- Create a new file
function M.create_file()
    -- Get the current working directory
    local cwd = vim.fn.getcwd()
    local notes_dir = cwd .. '/.maple'
    
    -- Ensure the .maple directory exists
    if not vim.fn.isdirectory(notes_dir) then
        vim.fn.mkdir(notes_dir, 'p')
    end
    
    -- Prompt for file name
    vim.ui.input({prompt = 'File name: '}, function(input)
        if not input or input == '' then return end
        
        -- Create the file in the .maple directory
        local file_path = notes_dir .. '/' .. input
        local fd = vim.loop.fs_open(file_path, 'w', 420) -- 0644 permissions
        if fd then
            vim.loop.fs_close(fd)
            M.refresh()
        else
            utils.notify('Failed to create file: ' .. file_path, 'error')
        end
    end)
end

-- Create a new folder
function M.create_folder()
    -- Get the current working directory
    local cwd = vim.fn.getcwd()
    local notes_dir = cwd .. '/.maple'
    
    -- Ensure the .maple directory exists
    if not vim.fn.isdirectory(notes_dir) then
        vim.fn.mkdir(notes_dir, 'p')
    end
    
    -- Prompt for folder name
    vim.ui.input({prompt = 'Folder name: '}, function(input)
        if not input or input == '' then return end
        
        -- Create the folder in the .maple directory
        local folder_path = notes_dir .. '/' .. input
        local success = vim.fn.mkdir(folder_path, 'p')
        if success == 1 then
            M.refresh()
        else
            utils.notify('Failed to create folder: ' .. folder_path, 'error')
        end
    end)
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
    if not is_open or not win or not api.nvim_win_is_valid(win) then return end
    
    -- Get the current line
    local line = api.nvim_get_current_line()
    -- Remove the icon and space at the start
    local filename = line:match('[^%s]+ (.+)$')
    if not filename then return end
    
    -- Get the path relative to the .maple directory
    local cwd = vim.fn.getcwd()
    local full_path = vim.fn.fnamemodify(cwd .. '/.maple/' .. filename, ':p')
    
    -- Check if it's a directory
    if vim.fn.isdirectory(full_path) == 1 then
        -- TODO: Handle directory navigation
        utils.notify('Directory navigation coming soon!', 'info')
        return
    end
    
    -- Create a new vertical split to the right of the panel
    vim.cmd('wincmd l')
    vim.cmd('vsplit')
    
    -- Open the file in the new split
    vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
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
