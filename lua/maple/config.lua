local M = {}

-- Default configuration
M.defaults = {
    -- Appearance
    width = 0.6,        -- Width of the popup (ratio of the editor width)
    height = 0.6,       -- Height of the popup (ratio of the editor height)
    border = 'rounded', -- Border style ('none', 'single', 'double', 'rounded', etc.)
    title = ' maple ',
    title_pos = 'center',
    winblend = 10,       -- Window transparency (0-100)
    show_legend = false, -- Whether to show keybind legend in the UI

    -- Storage
    storage_path = vim.fn.stdpath('data') .. '/maple',

    -- Notes management
    notes_mode = "project",            -- "global" or "project"
    use_project_specific_notes = true, -- Store notes by project

    -- Keymaps
    keymaps = {
        close = { 'q', 'Esc' },
        switch_mode = 'm', -- Toggle between global and project view
    },

    -- Global keybind
    set_default_keybind = true -- Set to false to disable the default <leader>m keybind
}

-- User configuration
M.options = {}

-- Setup function
function M.setup(opts)
    -- Merge user options with defaults
    M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
    return M.options
end

-- Initialize with defaults if not done already
if not M.options or not next(M.options) then
    M.setup({})
end

return M
