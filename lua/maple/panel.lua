local M = {}
local config = require('maple.config')
local fs = require('maple.fs')
local utils = require('maple.utils')

local buf = nil
local win = nil
local is_open = false
local tree_state = {}

local function init_dir()
    local notes_path = config.notes_dir
    if vim.fn.isdirectory(notes_path) == 0 then
        vim.fn.mkdir(notes_path, 'p')
    end
    return notes_path
end

local function norm_path(path)
    return path:gsub('/$', '')
end

local function node_id(path)
    return norm_path(path)
end

local function is_expanded(path)
    local id = node_id(path)
    return tree_state[id] and tree_state[id].expanded
end

local function set_expanded(path, expanded)
    local id = node_id(path)
    if not tree_state[id] then
        tree_state[id] = {}
    end
    tree_state[id].expanded = expanded
end

local function parent_path(path)
    return path:match('(.*)/[^/]+$') or path
end

local function build_tree(root_path)
    local lines = {}
    local line_to_path = {}

    local function add_dir_contents(dir_path, current_depth)
        local files = fs.scan_dir(dir_path)

        for _, file in ipairs(files) do
            local indent = string.rep('  ', current_depth)
            local icon = file.icon
            local expand_icon = ''

            if file.is_dir then
                expand_icon = is_expanded(file.path) and config.icons.folder_open or config.icons.folder_closed
                icon = ''
            end

            local line = indent .. expand_icon .. icon .. ' ' .. file.name
            table.insert(lines, line)
            line_to_path[#lines] = file.path

            if file.is_dir and is_expanded(file.path) then
                add_dir_contents(file.path, current_depth + 1)
            end
        end
    end

    add_dir_contents(root_path, 0)
    return lines, line_to_path
end

local function create_buffer()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'maple')
    vim.api.nvim_buf_set_name(buf, 'Maple')
    return buf
end

local function create_window()
    vim.cmd('vsplit')
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'winfixwidth', true)
    vim.api.nvim_win_set_width(win, config.width)

    local keymaps = config.keymaps
    local opts = { buffer = buf, silent = true }

    vim.keymap.set('n', '<CR>', M.toggle_item, opts)
    vim.keymap.set('n', 'l', M.expand_edit, opts)
    vim.keymap.set('n', 'h', M.collapse_parent, opts)
    vim.keymap.set('n', 'o', M.open_item, opts)
    vim.keymap.set('n', keymaps.create_file, M.create_file, opts)
    vim.keymap.set('n', keymaps.create_folder, M.create_folder, opts)
    vim.keymap.set('n', keymaps.delete, M.delete_item, opts)
    vim.keymap.set('n', keymaps.close, M.close, opts)
    vim.keymap.set('n', keymaps.refresh, M.refresh, opts)
    vim.keymap.set('n', keymaps.expand_all, M.expand_all, opts)
    vim.keymap.set('n', keymaps.collapse_all, M.collapse_all, opts)
    vim.keymap.set('n', keymaps.parent, M.go_parent, opts)
    vim.keymap.set('n', 'g?', M.show_help, opts)

    return win
end

local function open_right(file_path)
    vim.cmd('wincmd l')
    vim.cmd('vsplit ' .. vim.fn.fnameescape(file_path))
end

function M.refresh()
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local root_path = init_dir()
    local lines, line_to_path = build_tree(root_path)

    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    vim.b[buf].maple_line_to_path = line_to_path
end

function M.open()
    if is_open then
        return
    end

    local root_path = init_dir()
    set_expanded(root_path, true)

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        create_buffer()
    end

    if not win or not vim.api.nvim_win_is_valid(win) then
        create_window()
    end

    M.refresh()
    is_open = true
end

function M.close()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    is_open = false
    win = nil
end

function M.toggle()
    if is_open then
        M.close()
    else
        M.open()
    end
end

function M.current_path()
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end

    local line_to_path = vim.b[buf].maple_line_to_path
    if not line_to_path then
        return nil
    end

    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    return line_to_path[current_line]
end

function M.current_item()
    local path = M.current_path()
    if not path then
        return nil
    end

    local is_dir = vim.fn.isdirectory(path) == 1
    return {
        path = path,
        name = vim.fn.fnamemodify(path, ':t'),
        is_dir = is_dir,
        icon = is_dir and config.icons.folder or config.icons.file
    }
end

function M.toggle_item()
    local item = M.current_item()
    if not item then
        return
    end

    if item.is_dir then
        local was_expanded = is_expanded(item.path)
        set_expanded(item.path, not was_expanded)
        M.refresh()
    else
        open_right(item.path)
    end
end

function M.expand_edit()
    local item = M.current_item()
    if not item then
        return
    end

    if item.is_dir then
        if not is_expanded(item.path) then
            set_expanded(item.path, true)
            M.refresh()
        end
    else
        open_right(item.path)
    end
end

function M.collapse_parent()
    local item = M.current_item()
    if not item then
        return
    end

    if item.is_dir and is_expanded(item.path) then
        set_expanded(item.path, false)
        M.refresh()
    else
        M.go_parent()
    end
end

function M.go_parent()
    local item = M.current_item()
    if not item then
        return
    end

    local parent = parent_path(item.path)
    local root_path = init_dir()

    if parent and parent ~= item.path and #parent >= #root_path then
        M.focus_path(parent)
    end
end

function M.focus_path(target_path)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local line_to_path = vim.b[buf].maple_line_to_path
    if not line_to_path then
        return
    end

    for line_num, path in pairs(line_to_path) do
        if path == target_path then
            vim.api.nvim_win_set_cursor(win, { line_num, 0 })
            return true
        end
    end
    return false
end

function M.open_item()
    local item = M.current_item()
    if not item then
        return
    end

    if not item.is_dir then
        open_right(item.path)
    end
end

function M.expand_all()
    local root_path = init_dir()

    local function expand_recursive(dir_path)
        set_expanded(dir_path, true)
        local files = fs.scan_dir(dir_path)
        for _, file in ipairs(files) do
            if file.is_dir then
                expand_recursive(file.path)
            end
        end
    end

    expand_recursive(root_path)
    M.refresh()
end

function M.collapse_all()
    tree_state = {}
    local root_path = init_dir()
    set_expanded(root_path, true)
    M.refresh()
end

function M.create_file()
    local item = M.current_item()
    local parent_dir = item and item.is_dir and item.path or parent_path(item and item.path or init_dir())

    vim.ui.input({ prompt = 'File name: ' }, function(name)
        if not name or name == '' then return end
        if not name:match('%.') then name = name .. '.md' end
        if fs.create_file(parent_dir, name) then
            if item and item.is_dir then
                set_expanded(item.path, true)
            end
            M.refresh()
            utils.notify('Created file: ' .. name)
        else
            utils.notify('Failed to create file: ' .. name, 'error')
        end
    end)
end

function M.create_folder()
    local item = M.current_item()
    local parent_dir = item and item.is_dir and item.path or parent_path(item and item.path or init_dir())

    vim.ui.input({ prompt = 'Folder name: ' }, function(name)
        if not name or name == '' then return end
        if fs.create_dir(parent_dir, name) then
            if item and item.is_dir then
                set_expanded(item.path, true)
            end
            M.refresh()
            utils.notify('Created folder: ' .. name)
        else
            utils.notify('Failed to create folder: ' .. name, 'error')
        end
    end)
end

function M.delete_item()
    local item = M.current_item()
    if not item then
        return
    end

    local type_name = item.is_dir and 'folder' or 'file'
    vim.ui.input({
        prompt = 'Delete ' .. type_name .. ' "' .. item.name .. '"? (y/N): '
    }, function(confirm)
        if confirm and confirm:lower() == 'y' then
            if fs.delete_path(item.path) then
                local id = node_id(item.path)
                tree_state[id] = nil
                M.refresh()
                utils.notify('Deleted ' .. type_name .. ': ' .. item.name)
            else
                utils.notify('Failed to delete ' .. type_name .. ': ' .. item.name, 'error')
            end
        end
    end)
end

function M.show_help()
    local help_lines = {
        '',
        '                    Maple File Tree Help',
        '',
        'Navigation:',
        '  <CR>           - Open file or toggle directory',
        '  o              - Open file in new split',
        '  l              - Expand directory or open file',
        '  h              - Collapse directory or go to parent',
        '  P              - Go to parent directory',
        '',
        'Tree Operations:',
        '  E              - Expand all directories',
        '  W              - Collapse all directories',
        '  r              - Refresh tree',
        '',
        'File Operations:',
        '  a              - Create new file',
        '  A              - Create new directory',
        '  d              - Delete file/directory',
        '',
        'Other:',
        '  q              - Close file tree',
        '  g?             - Show this help',
        '',
        'Press any key to close this help...',
        ''
    }

    local help_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(help_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(help_buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(help_buf, 'modifiable', false)
    vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_lines)

    local width = 60
    local height = #help_lines
    local help_win = vim.api.nvim_open_win(help_buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = 'minimal',
        border = 'rounded',
        title = ' Maple Help ',
        title_pos = 'center'
    })

    vim.api.nvim_win_set_option(help_win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')

    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(help_win, true)
    end, { buffer = help_buf, silent = true })

    vim.keymap.set('n', '<CR>', function()
        vim.api.nvim_win_close(help_win, true)
    end, { buffer = help_buf, silent = true })

    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(help_win, true)
    end, { buffer = help_buf, silent = true })

    local group = vim.api.nvim_create_augroup('MapleHelp', { clear = true })
    vim.api.nvim_create_autocmd('BufWipeout', {
        group = group,
        buffer = help_buf,
        callback = function()
            if vim.api.nvim_win_is_valid(help_win) then
                vim.api.nvim_win_close(help_win, true)
            end
        end
    })
end

return M
