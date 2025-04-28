if exists('g:loaded_maple')
  finish
endif
let g:loaded_maple = 1

" Initialize with default configuration
lua require('maple').setup({})

command! MapleTodo lua require('maple').open_todo()
