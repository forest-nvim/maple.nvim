local api = vim.api
local config = require('maple.config')

local M = {}

local buf = nil
local win = nil

function M.create_buf()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Set buffer to be modifiable
    api.nvim_buf_set_option(buf, 'modifiable', true)
    
    -- Set filetype for syntax highlighting
    api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    
    return buf
end

function M.create_win()
    local width = math.floor(vim.o.columns * config.options.width)
    local height = math.floor(vim.o.lines * config.options.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local mode_text = ""
    if config.options.notes_mode == "global" then
        mode_text = "Global Notes"
    else
        mode_text = "Project Notes"
    end

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = config.options.border,
        title = ' Maple Notes ',
        title_pos = config.options.title_pos
    }

    win = api.nvim_open_win(buf, true, opts)
    api.nvim_win_set_option(win, 'winblend', config.options.winblend)
    
    -- Enable wrapping for better note editing
    api.nvim_win_set_option(win, 'wrap', true)
    api.nvim_win_set_option(win, 'linebreak', true)
    
    -- Show line numbers
    api.nvim_win_set_option(win, 'number', true)
    
    -- Set scrolloff to keep footer visible
    api.nvim_win_set_option(win, 'scrolloff', 3)
    
    return win
end

function M.close_win()
    if win and api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
        win = nil
    end
end

function M.get_buf()
    return buf
end

function M.get_win()
    return win
end

return M

