local MiniTest = require('mini.test')
local new_set = MiniTest.new_set

local T = new_set()

T['config'] = new_set()

T['config']['has correct defaults'] = function()
	-- Re-require to get fresh state
	package.loaded['maple.config'] = nil
	local config = require('maple.config')

	MiniTest.expect.equality(config.defaults.width, 0.6)
	MiniTest.expect.equality(config.defaults.height, 0.6)
	MiniTest.expect.equality(config.defaults.border, "rounded")
	MiniTest.expect.equality(config.defaults.title, " maple ")
	MiniTest.expect.equality(config.defaults.winblend, 10)
	MiniTest.expect.equality(config.defaults.notes_mode, "project")
	MiniTest.expect.equality(config.defaults.use_project_specific_notes, true)
end

T['config']['setup merges user options'] = function()
	package.loaded['maple.config'] = nil
	local config = require('maple.config')

	config.setup({ width = 0.8, border = "double" })

	MiniTest.expect.equality(config.options.width, 0.8)
	MiniTest.expect.equality(config.options.border, "double")
	-- Defaults should still be present
	MiniTest.expect.equality(config.options.height, 0.6)
	MiniTest.expect.equality(config.options.winblend, 10)
end

T['config']['deep merges nested tables'] = function()
	package.loaded['maple.config'] = nil
	local config = require('maple.config')

	config.setup({ preview = { enabled = false } })

	MiniTest.expect.equality(config.options.preview.enabled, false)
	MiniTest.expect.equality(config.options.preview.width, 0.4)
	MiniTest.expect.equality(config.options.preview.height, 0.3)
end

return T
