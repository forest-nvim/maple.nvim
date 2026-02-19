NVIM ?= nvim

.PHONY: test lint

test:
	$(NVIM) --headless -u tests/minimal_init.lua -c "lua require('mini.test').setup(); require('mini.test').run()" -c "qa!"

lint:
	luacheck lua/ --globals vim --no-max-line-length
