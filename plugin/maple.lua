-- This file is automatically loaded when the plugin is loaded

-- Only do this once per Neovim session
if vim.g.maple_loaded then
    return
end

vim.g.maple_loaded = true

-- Set up autocommands to handle panel behavior
local utils = require('maple.utils')

-- Close the panel when entering a buffer that's not a Maple buffer
utils.create_augroup('AutoClose', {
    {
        event = 'BufEnter',
        opts = {
            callback = function(args)
                if not utils.is_maple_buf(args.buf) then
                    local maple = require('maple.panel')
                    if maple.is_open then
                        maple.close()
                    end
                end
            end,
        },
    },
    {
        event = 'VimLeavePre',
        opts = {
            callback = function()
                local maple = require('maple.panel')
                if maple.is_open then
                    maple.close()
                end
            end,
        },
    },
})

-- Set up keymaps for the panel
local function setup_keymaps()
    -- These keymaps are only active when the panel is focused
    local keymaps = {
        { 'n', '<CR>', ':lua require("maple.panel").open_file()<CR>', { silent = true, buffer = true } },
        { 'n', 'o', ':lua require("maple.panel").open_file()<CR>', { silent = true, buffer = true } },
        { 'n', 'a', ':lua require("maple.panel").create_file()<CR>', { silent = true, buffer = true } },
        { 'n', 'd', ':lua require("maple.panel").create_folder()<CR>', { silent = true, buffer = true } },
        { 'n', 'r', ':lua require("maple.panel").rename()<CR>', { silent = true, buffer = true } },
        { 'n', 'D', ':lua require("maple.panel").delete()<CR>', { silent = true, buffer = true } },
        { 'n', 'R', ':lua require("maple.panel").refresh()<CR>', { silent = true, buffer = true } },
        { 'n', 'q', ':lua require("maple.panel").close()<CR>', { silent = true, buffer = true } },
        { 'n', '?', ':lua require("maple.panel").show_help()<CR>', { silent = true, buffer = true } },
    }
    
    for _, map in ipairs(keymaps) do
        vim.keymap.set(unpack(map))
    end
end

-- Set up autocommands for the panel buffer
utils.create_augroup('PanelBuffer', {
    {
        event = 'FileType',
        opts = {
            pattern = 'maple',
            callback = function()
                setup_keymaps()
            end,
        },
    },
})

-- Set up user commands
vim.api.nvim_create_user_command('MapleToggle', function()
    require('maple.panel').toggle()
end, { desc = 'Toggle Maple Notes panel' })

vim.api.nvim_create_user_command('MapleFocus', function()
    require('maple.panel').focus()
end, { desc = 'Focus Maple Notes panel' })

vim.api.nvim_create_user_command('MapleFindFile', function()
    -- TODO: Implement find file functionality
    utils.notify('Find file functionality coming soon!', 'info')
end, { desc = 'Find file in notes' })

vim.api.nvim_create_user_command('MapleNewFile', function()
    require('maple.panel').create_file()
end, { desc = 'Create a new note' })
