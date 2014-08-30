scriptencoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("leet")
let s:Json = s:V.import("Web.JSON")
let s:Random = s:V.import("Random")


let s:leet = {}
let s:file = expand('<sfile>:h').'/leet.json'
let s:leet_data = s:leet_load()


function! leet#convert(target, head, tail)
  "" ここ変換処理が重複しててやばい。どうにかしたい
  if type(a:target) == 1
    let l:leet_word = ''
    for char in split(toupper(a:target), '\zs')
      if has_key(s:leet_data, char)
        let l:leet_word = l:leet_word . s:Random.sample(s:leet_data[char])
      else
        let l:leet_word = l:leet_word . char
      endif
   endfor
   let l:newl = substitute(getline('.'), a:target, l:leet_word, 'g')
   call setline('.', l:newl)
  elseif type(a:target) == 3
    let l:result = []
    " 変換対象外の先頭部分を追加
    let l:leet_word = a:head
    for word in a:target
      for char in split(toupper(word), '\zs')
        if has_key(s:leet_data, char)
          let l:leet_word = l:leet_word . s:Random.sample(s:leet_data[char])
        else
          let l:leet_word = l:leet_word . char
        endif
     endfor
      let l:result += [l:leet_word]
      let l:leet_word = ''
    endfor
    " 変換対象外の後尾部分を追加
    let l:result[-1] = l:result[-1] . a:tail
    call setline('.', l:result)
  endif
endfunction


function! leet#current_pos()
  let l:target = expand("<cword>")
  call leet#convert(l:target, getpos('.'), 'dummy')
endfunction!


function! leet#selected_pos()
  let l:pos_info = s:get_selected_pos()
  call leet#convert(l:pos_info[0], l:pos_info[1], l:pos_info[2])
endfunction


function! s:leet_load()
  if empty(s:leet)
    let s:leet = s:Json.decode(join(readfile(s:file), "\n"))
  endif
  return s:leet
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
