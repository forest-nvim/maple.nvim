local M = {}
local api = vim.api
local storage = require('maple.storage')
local window = require('maple.ui.window')
local renderer = require('maple.ui.renderer')
local keymaps = require('maple.keymaps')

-- Setup function
function M.setup(config)
    config = config or {}
    -- You can add configuration options here if needed
    -- Set up default keybind if enabled
    if config.set_default_keybind ~= false then
        vim.keymap.set('n', '<leader>q', '<cmd>mapleTodo<CR>', {
            noremap = true,
            silent = true,
            desc = 'Open maple Todo List'
        })
    end
end

-- Open the todo window
function M.open_todo()
    local todos = storage.load_todos()
    window.create_buf()
    window.create_win()
    api.nvim_buf_set_option(window.get_buf(), 'modifiable', true)
    renderer.render_todos(todos)
    keymaps.setup_keymaps(todos)
end

return M
