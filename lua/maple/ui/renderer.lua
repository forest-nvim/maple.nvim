local api = vim.api
local window = require('maple.ui.window')
local config = require('maple.config')

local M = {}

local function render_subtasks(subtasks, indent_level)
    local lines = {}
    for _, subtask in ipairs(subtasks) do
        if subtask then
            local status = subtask.completed and "[✓]" or "[ ]"
            local indent = string.rep("  ", indent_level)
            table.insert(lines, string.format("%s%s %s", indent, status, subtask.text or ""))
            
            if subtask.subtasks and #subtask.subtasks > 0 then
                local subtask_lines = render_subtasks(subtask.subtasks, indent_level + 1)
                for _, line in ipairs(subtask_lines) do
                    table.insert(lines, line)
                end
            end
        end
    end
    return lines
end

function M.render_todos(todos)
    local lines = {}

    for i, todo in ipairs(todos) do
        if todo then
            local status = todo.completed and "[✓]" or "[ ]"
            table.insert(lines, string.format("  %d %s %s", i, status, todo.text or ""))
            
            if todo.subtasks and #todo.subtasks > 0 then
                local subtask_lines = render_subtasks(todo.subtasks, 3)
                for _, line in ipairs(subtask_lines) do
                    table.insert(lines, line)
                end
            end
        end
    end

    table.insert(lines, "")

    local mode_text = ""
    if config.options.todo_mode == "global" then
        mode_text = "Global Todo Items"
    else
        mode_text = "Project Todo Items"
    end

    local legend_items = {
        string.format("[%s] Add", 'a'),
        string.format("[%s] Toggle", 'x'),
        string.format("[%s] Delete", 'd'),
        string.format("[%s] Switch Mode", 'm'),
        string.format("[%s] Add Subtask", 'n'),
        string.format("[%s] Close", 'q')
    }

    table.insert(lines, "  " .. table.concat(legend_items, "  "))
    table.insert(lines, string.format("  Mode: %s", mode_text))

    local buf = window.get_buf()
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
