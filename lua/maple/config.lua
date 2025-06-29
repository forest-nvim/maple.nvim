local M = {}

M.width = 35
M.notes_dir = vim.fn.stdpath('data') .. '/maple/notes'

M.icons = {
    folder = '📁',
    folder_open = '▼',
    folder_closed = '▶',
    file = '•'
}

M.keymaps = {
    create_file = 'a',
    create_folder = 'A',
    delete = 'd',
    close = 'q',
    refresh = 'r',
    expand_all = 'E',
    collapse_all = 'W',
    parent = 'P'
}

return M
