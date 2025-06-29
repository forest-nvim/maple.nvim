local M = {}

function M.notify(msg, level)
    level = level or 'info'
    vim.notify(msg, vim.log.levels[level:upper()])
end

return M
