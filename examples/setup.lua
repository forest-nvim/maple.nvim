-- Example configuration for maple.nvim
-- This file is provided as a reference to help you set up maple.nvim

-- Basic setup with default options
require('maple').setup()

-- Custom setup with options
require('maple').setup({
    -- Appearance customization
    width = 0.7,              -- Make the popup slightly wider
    height = 0.8,             -- Make the popup taller
    border = 'double',        -- Use double-line borders
    title = ' My Todo List ', -- Custom title
    title_pos = 'left',       -- Position the title on the left
    winblend = 15,            -- Slightly more transparent

    -- Custom keymaps
    keymaps = {
        add = 'n',                        -- Press 'n' to create a new todo
        toggle = 't',                     -- Press 't' to toggle completion
        delete = 'D',                     -- Press 'D' to delete a todo
        close = { 'q', '<Esc>', '<C-c>' } -- More ways to close the window
    }
})

-- Creating a keymap to open the todo list
vim.keymap.set('n', '<leader>t', '<cmd>MapleNotes<CR>', {
    noremap = true,
    silent = true,
    desc = 'Open maple Todo List'
})
