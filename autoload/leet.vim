scriptencoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("leet")
let s:Json = s:V.import("Web.JSON")
let s:Random = s:V.import("Random")

let s:leet = {}

let s:file = expand('<sfile>:h').'/leet.json'
let s:leet_data = s:leet_load()

function! leet#convert(target)
  let l:result = ''
  for i in  split(toupper(a:target), '\zs')
    if i != ' '
      let l:rand_range = s:Random.range(0, len(s:leet_data[i])-1)
      let l:result = l:result . s:leet_data[i][l:rand_range]
    else
      let l:result = l:result . i
    endif
  endfor
  call setline('.', substitute(getline('.'), a:target, l:result, 'g'))
endfunction

function! leet#current_pos()
  let l:target = expand("<cword>")
  call leet#convert(l:target)
endfunction!

function! leet#selected_pos()
  let l:target = s:get_selected_pos()
  call leet#convert(l:target)
endfunction

function! s:leet_load()
  if empty(s:leet)
    let s:leet = s:Json.decode(join(readfile(s:file), "\n"))
  endif
  return s:leet
endfunction

function! s:get_selected_pos()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
