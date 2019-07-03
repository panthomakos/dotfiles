function! GetBufferList()
  redir =>buflist
  silent! ls
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

" Given a line-break separated file of filenames, add all of the listed
" files to the quickfix list.
"
" Example (open `.vimrc` and `.zshrc`):
"
"     $ cat foo
"     .vimrc
"     .zshrc
"     $ vim
"     :call OpenFileList("foo")
function! OpenFileList(filename)
  set errorformat=%f
  exec('cf '.a:filename)
endfunction

nmap <silent> <leader>L :call ToggleList("Location List", 'l')<CR>
nmap <silent> <leader>E :call ToggleList("Quickfix List", 'c')<CR>
