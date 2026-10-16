NVIM ?= nvim

.PHONY: test

test: deps/mini.nvim
	$(NVIM) --headless --clean --cmd "set rtp^=. rtp+=deps/mini.nvim noswapfile" -c "lua require('mini.test').setup(); require('mini.test').run()" -c cq

deps/mini.nvim:
	git clone --filter=blob:none --branch stable https://github.com/echasnovski/mini.nvim $@
