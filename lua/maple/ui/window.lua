local api = vim.api
local config = require('maple.config')

local M = {}

local buf = nil
local win = nil

function M.create_buf()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    return buf
end

function M.create_win()
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local mode_text = ""
    if config.options.todo_mode == "global" then
        mode_text = "Global Todo Items"
    else
        mode_text = "Project Todo Items"
    end

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' Maple ',
        title_pos = 'left'
    }

    win = api.nvim_open_win(buf, true, opts)
    api.nvim_win_set_option(win, 'winblend', 0)
    return win
end

function M.close_win()
    if win then
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

