scriptencoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("leet")
let s:Json = s:V.import("Web.JSON")
let s:Random = s:V.import("Random")


let s:leet = {}
let s:file = expand('<sfile>:h').'/leet.json'
let s:leet_data = s:leet_load()


function! leet#convert(target, word)
  let l:leet_word = a:word
  for char in split(toupper(a:target), '\zs')
    if has_key(s:leet_data, char)
      let l:leet_word = l:leet_word . s:Random.sample(s:leet_data[char])
    else
      let l:leet_word = l:leet_word . char
    endif
  endfor
  return l:leet_word
endfunction


" カーソル位置の1単語を変換
function! leet#current_pos()
  let l:target = expand("<cword>")
  let l:leftside = split(getline('.')[: getpos('.')[2]==1?0:getpos('.')[2]], '\W')
  let l:leet_word = leet#convert(l:target, '')

  " 位置を特定して単語を変換する
  "" 実装やばすぎるので改善したい{{{1
  let l:tmp = split(getline('.'), '\W')
  let l:tmp[len(l:leftside)-1] = l:leet_word
  let l:words = []
  for w in l:tmp
    if w != ''
      let l:words += ["'". w . "'"]
    endif
  endfor

  let l:format = substitute(getline('.'), '\w\+', '%s', 'g')
  let l:newl = ''
  "" printfの引数は18個までしかとれないので越えてたら分割する
  if len(l:words) > 18
    let l:start = 0
    for i in range(1+len(l:words)/18)
      let l:count = len(l:words)==i?len(l:words)%18==0?18:len(l:words)%18:18
      let l:index = matchend(l:format, '\v(\%s)', l:start, l:count)
      let l:args = 'printf("' . l:format[l:start : l:index] . '", ' .
            \ join(l:words[i*18:i*18+l:count-1], ', ') . ')'
      execute 'let l:result = ' . l:args
      let l:newl = l:newl . l:result
      unlet l:result
      let l:start = l:index+1
    endfor
  else
    let l:args = 'printf("' . l:format . '", ' . join(l:words, ', ') . ')'
    execute 'let l:newl = ' . l:args
  endif
  call setline('.', l:newl)
  "" }}}1
endfunction!

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
