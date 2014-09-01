scriptencoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("leet")
let s:Json = s:V.import("Web.JSON")
let s:Random = s:V.import("Random")
let s:Search = s:V.import("Coaster.Search")
let s:Buffer = s:V.import("Coaster.Buffer")

let s:leet_dict = {}
let s:file = expand('<sfile>:h').'/leet.json'


function! leet#convert(target, word)
  call s:leet_load()
  let l:leet_word = a:word
  for char in split(toupper(a:target), '\zs')
    if has_key(s:leet_dict, char)
      let l:leet_word = l:leet_word . s:Random.sample(s:leet_dict[char])
    else
      let l:leet_word = l:leet_word . char
    endif
  endfor
  return l:leet_word
endfunction


" カーソル位置の1単語を変換
function! leet#current_pos()
  let [l:first, l:last] = s:Search.region('\w\+', "Wncb", "Wnce")
  if l:first == [0, 0] || l:last == [0, 0]
    return
  endif
  let l:cword = s:Buffer.get_text_from_region([0] + l:first + [0], [0] + l:last + [0], "v")
  if l:cword !~ '\w\+'
    return
  endif
  let l:leet_word = leet#convert(l:cword, '')
  call s:Buffer.paste_for_text('v', l:first, l:last, l:leet_word)
endfunction

" 選択範囲の文字を変換
function! leet#selected_pos()
  let [l:target, l:head, l:tail] = s:get_selected_pos()
  let l:result = []

  " 変換対象外の先頭部分を追加
  let l:leet_word = l:head
  for word in l:target
    let l:leet_word = leet#convert(word, l:leet_word)
    let l:result += [l:leet_word]
    let l:leet_word = ''
  endfor
  " 変換対象外の後尾部分を追加
  let l:result[-1] = l:result[-1] . l:tail
  call setline('.', l:result)
endfunction


function! s:leet_load()
  if empty(s:leet_dict)
    let s:leet_dict = s:Json.decode(join(readfile(s:file), "\n"))
  endif
endfunction


function! s:get_selected_pos()
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]

  " 変換対象の抽出
  let l:select_lines = getline(l:lnum1, l:lnum2)
  let l:select_lines[-1] = l:select_lines[-1][:l:col2-(&selection=='inclusive'?1:2)]
  let l:select_lines[0] = l:select_lines[0][l:col1-1:]

  " 変換対象外の抽出
  let l:not_select_head = l:col1-2 < 0 ? '' : getline(l:lnum1)[0:l:col1-2]
  let l:not_select_tail = getline(l:lnum2)[l:col2 :]

  return [l:select_lines, l:not_select_head, l:not_select_tail]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
