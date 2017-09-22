" Convert a single line Ruby method call into a multi-line method call.
function! MakeRubyMethodMultiline()
  :normal! dd
  :normal! P
  mark y
  " Add newlines for opening braces and commas.
  :.s/\([,{(]\)/\1\r/g
  mark z
  " Add newlines for closing braces.
  :'y,'zs/\s*\([})]\)/\r\1/g
  :normal v'y
  :normal ==
  :nohlsearch
endfunction

autocmd FileType ruby map <buffer> <leader>mm :call MakeRubyMethodMultiline()<cr>

" Convert a single line Ruby block into a multi-line block.
function! MakeRubyBlockMultiline()
  :normal! dd
  :normal! P
  :.s/{\s*/do\r/
  :.s/\s*}$/\rend/
  :normal v%
  :normal ==
  :nohlsearch
endfunction

autocmd FileType ruby map <buffer> <leader>mb :call MakeRubyBlockMultiline()<cr>
