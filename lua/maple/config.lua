local M = {}

-- Default configuration
M.defaults = {
    -- Appearance
    width = 0.6,        -- Width of the popup (ratio of the editor width)
    height = 0.6,       -- Height of the popup (ratio of the editor height)
    border = 'rounded', -- Border style ('none', 'single', 'double', 'rounded', etc.)
    title = ' maple ',
    title_pos = 'center',
    winblend = 10, -- Window transparency (0-100)

    -- Storage
    storage_path = vim.fn.stdpath('data') .. '/maple',
    db_path = vim.fn.stdpath('data') .. '/maple/maple.db',

    -- Database options
    use_sqlite = true, -- Use SQLite if available (falls back to JSON if not)

    -- Todo management
    todo_mode = "combined",            -- "global", "project", or "combined"
    use_project_specific_todos = true, -- Store todos by project

    -- Keymaps
    keymaps = {
        add = 'a',
        toggle = 'x',
        delete = 'd',
        close = { 'q', 'Esc' },
        switch_mode = 'm' -- Toggle between global, project, and combined view
    },

    -- Global keybind
    set_default_keybind = true -- Set to false to disable the default <leader>q keybind
}

-- User configuration
M.options = {}

-- Setup function
function M.setup(opts)
    -- Merge user options with defaults
    M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
    return M.options
end

return M
