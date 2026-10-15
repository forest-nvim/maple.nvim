NVIM ?= nvim

.PHONY: test lint

test: deps/mini.nvim
	$(NVIM) --headless --clean --cmd "set rtp^=. rtp+=deps/mini.nvim noswapfile" -c "lua require('mini.test').setup(); require('mini.test').run()" -c "qa!"

deps/mini.nvim:
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

lint:
	luacheck lua/ plugin/ --globals vim --no-max-line-length
