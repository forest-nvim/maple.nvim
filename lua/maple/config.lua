local M = {}
M.options = {}

-- Default configuration
local defaults = {
    -- Panel settings
    width = 30,
    position = 'left',  -- 'left' or 'right'
    auto_close = false,
    auto_refresh = true,
    respect_gitignore = true,
    
    -- File icons
    icons = {
        default = '📄',
        symlink = '🔗',
        folder = {
            default = '📁',
            open = '📂',
            empty = '📁',
            empty_open = '📂',
            symlink = '🔗',
            symlink_open = '🔗',
        },
    },
    
    -- Keymaps
    keymaps = {
        toggle = '<leader>m',
        create_file = 'a',
        create_folder = 'd',
        rename = 'r',
        delete = 'D',
        close = 'q',
        refresh = 'R',
    },
    
    -- Notes management
    notes_dir = vim.fn.stdpath('data') .. '/maple/notes',
    
    -- UI
    highlight_opened_files = true,
    hide_dotfiles = true,
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
}

-- Merge default options with user options
function M.setup(user_config)
    M.options = vim.tbl_deep_extend('force', defaults, user_config or {})
    
    -- Ensure global notes directory exists
    vim.fn.mkdir(M.options.global_notes, 'p')
end

return M
