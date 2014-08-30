scriptencoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("leet")
let s:Json = s:V.import("Web.JSON")
let s:Random = s:V.import("Random")

let s:leet = {}

let s:file = expand('<sfile>:h').'/leet.json'

function! leet#convert()
  let l:leet_data = s:leet_load()
  let l:target = expand("<cword>")
  let l:result = ''
  for i in  split(toupper(l:target), '\zs')
    let l:rand_range = s:Random.range(0, len(l:leet_data[i])-1)
    let l:result = l:result . l:leet_data[i][l:rand_range]
  endfor
  call setline('.', substitute(getline('.'), l:target, l:result, 'g'))
endfunction

function! s:leet_load()
  if empty(s:leet)
    let s:leet = s:Json.decode(join(readfile(s:file), "\n"))
  endif
  return s:leet
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
