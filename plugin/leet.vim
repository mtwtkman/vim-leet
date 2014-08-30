if exists("g:loaded_leet")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 Leet call leet#current_pos()
noremap <Plug>(leet-current_pos) :<C-u>Leet<CR>
noremap <Plug>(leet-selected_pos) :<C-u>call leet#selected_pos()<CR>

map <silent><Leader>L <Plug>(leet-selected_pos)

let &cpo = s:save_cpo
unlet s:save_cpo
