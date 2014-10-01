function! CompileAndRunC()
  let t:filename=@%

  " Write the current file, then compile and execute it.
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo

  :silent exec ':!echo Compiling and running...'
  :exec ':!gcc -std=c11 '.t:filename.' && ./a.out'
endfunction

autocmd FileType c map <buffer> <leader>t :call CompileAndRunC()<cr>
