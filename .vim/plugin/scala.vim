function! OpenScalaWorksheet()
  :call VimuxRunCommand("scala")
endfunction

function! RunScalaWorksheet()
  " Reset and clear the console.
  :call VimuxRunCommand(":reset")
  :call VimuxSendKeys("C-l")
  :call VimuxRunCommand(":paste -raw")
  :let s:raw=1

  " Iterate through each line and paste it into the console.
  let s:cursor=1
  let s:final=line("$")
  " TODO: iterate up to ignore empty lines and comments
  let s:session=0
  while (s:cursor <= s:final)
    let line = getline(s:cursor)
    if (line == "object session {")
      :call VimuxSendKeys("C-d")
      let s:raw=0
      let s:session=1
    elseif (line != "" && (s:session != 1 || s:cursor != s:final))
      :call VimuxRunCommand(getline(s:cursor))
    endif
    let s:cursor += 1
  endwhile

  " If we didn't open a session, ensure we exit paste mode.
  if (s:raw == 1)
    :call VimuxSendKeys("C-d")
    let s:raw=0
  endif
endfunction

autocmd FileType scala map <buffer> <leader>o :call OpenScalaWorksheet()<cr>
autocmd FileType scala map <buffer> <leader>r :call RunScalaWorksheet()<cr>
