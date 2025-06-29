local M = {}
local config = require('maple.config')
local panel = require('maple.panel')
local utils = require('maple.utils')

-- Setup function
function M.setup(user_config)
    -- Initialize configuration
    config.setup(user_config or {})
    
    -- Ensure the notes directory exists
    vim.fn.mkdir(config.options.notes_dir, 'p')
    
    -- Set up commands
    vim.api.nvim_create_user_command('MapleToggle', function()
        panel.toggle()
    end, { desc = 'Toggle Maple Notes panel' })
    
    vim.api.nvim_create_user_command('MapleFocus', function()
        panel.focus()
    end, { desc = 'Focus Maple Notes panel' })
    
    vim.api.nvim_create_user_command('MapleFindFile', function()
        -- TODO: Implement find file functionality
        utils.notify('Find file functionality coming soon!', 'info')
    end, { desc = 'Find file in notes' })
    
    vim.api.nvim_create_user_command('MapleNewFile', function()
        panel.create_file()
    end, { desc = 'Create a new note' })
    
    -- Set up keymaps if provided
    if config.options.keymaps.toggle then
        vim.keymap.set('n', config.options.keymaps.toggle, '<cmd>MapleToggle<CR>', {
            noremap = true,
            silent = true,
            desc = 'Toggle Maple Notes'
        })
    end
end

return M
