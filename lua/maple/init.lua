local M = {}
local api = vim.api
local config = require('maple.config')
local storage = require('maple.storage')
local window = require('maple.ui.window')
local renderer = require('maple.ui.renderer')
local keymaps = require('maple.keymaps')

-- Setup function
function M.setup(user_config)
    -- Initialize configuration
    config.setup(user_config or {})
    
    -- Set up default keybind if enabled
    if config.options.set_default_keybind ~= false then
        vim.keymap.set('n', '<leader>m', '<cmd>MapleNotes<CR>', {
            noremap = true,
            silent = true,
            desc = 'Open Maple Notes'
        })
    end
end

-- Open the notes window
function M.open_notes()
    -- Make sure config is initialized if M.setup wasn't called
    if not config.options or not next(config.options) then
        config.setup({})
    end
    
    local notes = storage.load_notes()
    window.create_buf()
    window.create_win()
    api.nvim_buf_set_option(window.get_buf(), 'modifiable', true)
    renderer.render_notes(notes)
    keymaps.setup_keymaps(notes)
end

return M
