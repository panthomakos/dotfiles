function! CompileAndRunElixir()
  let t:filename=@%

  " Write the current file, then compile and execute it.
  :w
  :silent !echo;echo;echo;echo;echo
  :silent exec ':!echo Compiling and running...'
  :exec ':!elixir '.t:filename
endfunction

autocmd FileType elixir map <buffer> <leader>t :call CompileAndRunElixir()<cr>
