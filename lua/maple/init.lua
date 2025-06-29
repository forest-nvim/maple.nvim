local M = {}
local panel = require('maple.panel')
local config = require('maple.config')

function M.setup(opts)
    opts = opts or {}

    -- Merge user config with defaults
    if opts.width then
        config.width = opts.width
    end

    if opts.notes_dir then
        config.notes_dir = opts.notes_dir
    end

    if opts.icons then
        config.icons = vim.tbl_deep_extend('force', config.icons, opts.icons)
    end

    if opts.keymaps then
        config.keymaps = vim.tbl_deep_extend('force', config.keymaps, opts.keymaps)
    end

    -- Set up the toggle command
    vim.api.nvim_create_user_command('MapleToggle', function()
        panel.toggle()
    end, { desc = 'Toggle Maple file tree' })

    -- Set up the default keybind
    local keybind = opts.keybind or '<leader>m'
    if keybind then
        vim.keymap.set('n', keybind, '<cmd>MapleToggle<CR>', {
            desc = 'Toggle Maple file tree',
            silent = true
        })
    end
end

return M
