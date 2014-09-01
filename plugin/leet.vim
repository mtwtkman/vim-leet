if exists("g:loaded_leet")
  finish
endif
let g:loaded_leet = 1

let s:save_cpo = &cpo
set cpo&vim


command! -nargs=0 Leet call leet#current_pos()
noremap <silent> <Plug>(leet-current_pos) :<C-u>Leet<CR>
vnoremap <silent> <Plug>(leet-selected_pos) :<C-u>call leet#selected_pos()<CR>

if !hasmapto('<Plug>(leet-selected_pos)')
  silent! map <unique> <Leader>L <Plug>(leet-selected_pos)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
