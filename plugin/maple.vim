if exists('g:loaded_maple')
  finish
endif
let g:loaded_maple = 1

command! MapleToggle lua require('maple').toggle()
command! MapleToggleFloat lua require('maple').toggle('float')
command! MapleToggleSplit lua require('maple').toggle('split')
command! MapleToggleVsplit lua require('maple').toggle('vsplit')
command! MapleToggleBuffer lua require('maple').toggle('buffer')
command! MapleClose lua require('maple').close()
command! MapleSwitchMode lua require('maple').switch_mode()
command! MapleToggleCheckbox lua require('maple').toggle_checkbox()
command! MapleAddCheckbox lua require('maple').add_checkbox()
command! -nargs=? MapleSearch lua require('maple').search_notes(<f-args>)