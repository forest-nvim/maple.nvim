local api = vim.api
local window = require('maple.ui.window')
local storage = require('maple.storage')
local renderer = require('maple.ui.renderer')
local config = require('maple.config')

local M = {}

function M.setup_keymaps(notes_data)
    local buf = window.get_buf()
    local win = window.get_win()
    
    -- Set up autocmd to save notes on buffer change and window close
    local save_augroup = api.nvim_create_augroup("MapleNotesSave", { clear = true })
    
    api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
        group = save_augroup,
        buffer = buf,
        callback = function()
            local content = renderer.get_notes_content()
            storage.save_notes({ content = content })
        end
    })

    -- Set up a basic key mapping function
    local function set_keymap(key, callback)
        if key then
            api.nvim_buf_set_keymap(buf, 'n', key, '', {
                noremap = true,
                silent = true,
                callback = callback
            })
        end
    end

    -- Switch between global and project notes
    set_keymap(config.options.keymaps.switch_mode, function()
        -- Save current notes before switching
        local content = renderer.get_notes_content()
        storage.save_notes({ content = content })
        
        -- Toggle mode
        if config.options.notes_mode == "global" then
            config.options.notes_mode = "project"
        else
            config.options.notes_mode = "global"
        end
        
        -- Reset storage and load notes for new mode
        storage.reset()
        local new_notes = storage.load_notes()
        
        -- Render notes
        api.nvim_buf_set_option(buf, 'modifiable', true)
        renderer.render_notes(new_notes)
    end)

    -- Close window
    set_keymap(config.options.keymaps.close, function()
        -- Save notes before closing
        local content = renderer.get_notes_content()
        storage.save_notes({ content = content })
        window.close_win()
    end)

    -- Enable editing
    api.nvim_buf_set_option(buf, 'modifiable', true)
end

return M
