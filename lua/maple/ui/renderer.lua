local api = vim.api
local window = require('maple.ui.window')

local M = {}

function M.render_todos(todos)
    local lines = {}

    for i, todo in ipairs(todos) do
        local status = todo.completed and "[✓]" or "[ ]"
        table.insert(lines, string.format("  %d %s %s", i, status, todo.text))
    end

    table.insert(lines, "")

    local legend_items = {
        string.format("[%s] Add", 'a'),
        string.format("[%s] Toggle", 'x'),
        string.format("[%s] Delete", 'd'),
        string.format("[%s] Close", 'q')
    }

    table.insert(lines, "  " .. table.concat(legend_items, "  "))

    local buf = window.get_buf()
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
