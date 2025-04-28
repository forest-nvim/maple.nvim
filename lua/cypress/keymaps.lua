local api = vim.api
local window = require('maple.ui.window')
local storage = require('maple.storage')
local renderer = require('maple.ui.renderer')

local M = {}

function M.setup_keymaps(todos)
    local buf = window.get_buf()
    local win = window.get_win()

    local function set_keymap(key, callback)
        api.nvim_buf_set_keymap(buf, 'n', key, '', {
            noremap = true,
            silent = true,
            callback = callback
        })
    end

    set_keymap('a', function()
        vim.ui.input({ prompt = 'New todo: ' }, function(input)
            if input and input ~= '' then
                table.insert(todos, { text = input, completed = false })
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        end)
    end)

    set_keymap('x', function()
        local current_line = api.nvim_win_get_cursor(win)[1]
        for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if i == current_line then
                local todo_idx = tonumber(line:match("^%s*(%d+)"))
                if todo_idx and todos[todo_idx] then
                    todos[todo_idx].completed = not todos[todo_idx].completed
                    storage.save_todos(todos)
                    api.nvim_buf_set_option(buf, 'modifiable', true)
                    renderer.render_todos(todos)
                    break
                end
            end
        end
    end)

    set_keymap('d', function()
        local current_line = api.nvim_win_get_cursor(win)[1]
        for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if i == current_line then
                local todo_idx = tonumber(line:match("^%s*(%d+)"))
                if todo_idx and todos[todo_idx] then
                    table.remove(todos, todo_idx)
                    storage.save_todos(todos)
                    api.nvim_buf_set_option(buf, 'modifiable', true)
                    renderer.render_todos(todos)
                    break
                end
            end
        end
    end)

    set_keymap('q', window.close_win)
    set_keymap('<Esc>', window.close_win)
end

return M
