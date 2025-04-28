local api = vim.api
local window = require('maple.ui.window')
local storage = require('maple.storage')
local renderer = require('maple.ui.renderer')
local config = require('maple.config')

local M = {}

function M.setup_keymaps(todos)
    local buf = window.get_buf()
    local win = window.get_win()

    local function set_keymap(key, callback)
        api.nvim_buf_set_keymap(buf, 'n', key, '', {
            noremap = true,
            silent = true,
            callback = callback
        })
    end

    set_keymap('a', function()
        vim.ui.input({ prompt = 'New todo: ' }, function(input)
            if input and input ~= '' then
                table.insert(todos, { text = input, completed = false, is_global = config.options.todo_mode == "global", subtasks = {} })
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        end)
    end)

    set_keymap('m', function()
        if config.options.todo_mode == "global" then
            config.options.todo_mode = "project"
        else
            config.options.todo_mode = "global"
        end
        storage.reset()
        todos = storage.load_todos()
        api.nvim_buf_set_option(buf, 'modifiable', true)
        renderer.render_todos(todos)
    end)

    -- Improved helper function to parse task lines and reliably find parent task and subtask path
    local function parse_task_line(line_number)
        local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
        local current_line = lines[line_number]
        
        -- Check if this is a main task line (has a number at the beginning)
        local main_task_index = tonumber(current_line:match("^%s*(%d+)"))
        if main_task_index then
            return { main_task = main_task_index }
        end
        
        -- Check if this is a subtask line (has checkbox but no number)
        if current_line:match("^%s*%[") then
            -- Find parent task by going up until we find a main task line
            local parent_line = line_number - 1
            while parent_line > 0 do
                local line = lines[parent_line]
                if line:match("^%s*%d+") then
                    -- Found parent main task
                    local main_index = tonumber(line:match("^%s*(%d+)"))
                    
                    -- Now build the subtask path from main task to current subtask
                    local path = {}
                    local current_indent = #current_line:match("^(%s*)")
                    
                    -- Map of indent levels to current index at that level
                    local level_indices = {}
                    
                    -- Process all lines between main task and current subtask
                    for i = parent_line + 1, line_number do
                        local l = lines[i]
                        if l:match("^%s*%[") then
                            local indent = #l:match("^(%s*)")
                            
                            -- Reset indices for deeper levels when going back to a more shallow level
                            for level, _ in pairs(level_indices) do
                                if level > indent then
                                    level_indices[level] = nil
                                end
                            end
                            
                            -- Initialize or increment the counter for this indent level
                            level_indices[indent] = (level_indices[indent] or 0) + 1
                            
                            -- If we're at our target line, build the final path
                            if i == line_number then
                                local sorted_levels = {}
                                for level, _ in pairs(level_indices) do
                                    table.insert(sorted_levels, level)
                                end
                                table.sort(sorted_levels)
                                
                                for _, level in ipairs(sorted_levels) do
                                    table.insert(path, level_indices[level])
                                end
                                
                                return {
                                    main_task = main_index,
                                    subtask_path = path
                                }
                            end
                        end
                    end
                    
                    break
                elseif not line:match("^%s*$") then -- Skip empty lines
                    parent_line = parent_line - 1
                else
                    parent_line = parent_line - 1
                end
            end
        end
        
        return nil
    end
    
    -- Improved helper function to get a subtask by path
    local function get_subtask_by_path(todo, path)
        if not path or #path == 0 then
            return nil, nil, nil
        end
        
        local current = todo
        local parent = nil
        local index = nil
        
        for i, pos in ipairs(path) do
            if not current.subtasks then
                current.subtasks = {}
            end
            
            if pos > #current.subtasks then
                return nil, nil, nil
            end
            
            parent = current
            index = pos
            current = current.subtasks[pos]
        end
        
        return current, parent, index
    end

    set_keymap('x', function()
        local current_line = api.nvim_win_get_cursor(win)[1]
        local result = parse_task_line(current_line)
        
        if not result then return end
        
        if result.main_task and not result.subtask_path then
            -- Toggle main task
            if todos[result.main_task] then
                todos[result.main_task].completed = not todos[result.main_task].completed
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        elseif result.main_task and result.subtask_path then
            -- Toggle subtask
            local main_task = todos[result.main_task]
            if not main_task then return end
            
            local subtask, _, _ = get_subtask_by_path(main_task, result.subtask_path)
            
            if subtask then
                subtask.completed = not subtask.completed
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        end
    end)

    set_keymap('d', function()
        local current_line = api.nvim_win_get_cursor(win)[1]
        local result = parse_task_line(current_line)
        
        if not result then return end
        
        if result.main_task and not result.subtask_path then
            -- Delete main task
            if todos[result.main_task] then
                table.remove(todos, result.main_task)
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        elseif result.main_task and result.subtask_path then
            -- Delete subtask
            local main_task = todos[result.main_task]
            if not main_task then return end
            
            local _, parent, index = get_subtask_by_path(main_task, result.subtask_path)
            
            if parent and parent.subtasks and index then
                table.remove(parent.subtasks, index)
                storage.save_todos(todos)
                api.nvim_buf_set_option(buf, 'modifiable', true)
                renderer.render_todos(todos)
            end
        end
    end)

    set_keymap('n', function()
        local current_line = api.nvim_win_get_cursor(win)[1]
        local result = parse_task_line(current_line)
        
        if not result then return end
        
        vim.ui.input({ prompt = 'Add subtask: ' }, function(input)
            if not input or input == '' then
                return
            end
            
            if result.main_task and not result.subtask_path then
                -- Add subtask to main task
                if todos[result.main_task] then
                    if not todos[result.main_task].subtasks then
                        todos[result.main_task].subtasks = {}
                    end
                    table.insert(todos[result.main_task].subtasks, {
                        text = input,
                        completed = false,
                        subtasks = {}
                    })
                    storage.save_todos(todos)
                    api.nvim_buf_set_option(buf, 'modifiable', true)
                    renderer.render_todos(todos)
                end
            elseif result.main_task and result.subtask_path then
                -- Add subtask to a subtask
                local main_task = todos[result.main_task]
                if not main_task then return end
                
                local subtask = get_subtask_by_path(main_task, result.subtask_path)
                
                if subtask then
                    if not subtask.subtasks then
                        subtask.subtasks = {}
                    end
                    table.insert(subtask.subtasks, {
                        text = input,
                        completed = false,
                        subtasks = {}
                    })
                    storage.save_todos(todos)
                    api.nvim_buf_set_option(buf, 'modifiable', true)
                    renderer.render_todos(todos)
                end
            end
        end)
    end)

    set_keymap('q', window.close_win)
    set_keymap('<Esc>', window.close_win)
end

return M
