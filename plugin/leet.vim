if exists("g:loaded_leet")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 Leet call leet#convert()
noremap <Plug>(leet-convert) :<C-u>Leet<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
