function! CompileAndRunElixir()
  let t:filename=@%

  " Write the current file, then compile and execute it.
  :w
  :silent !echo;echo;echo;echo;echo
  :silent exec ':!echo Compiling and running...'
  :exec ':!elixir '.t:filename
endfunction

autocmd FileType elixir map <buffer> <leader>r :call CompileAndRunElixir()<cr>

function! TestElixir()
  let t:filename=@%

  " Write the current file, then compile and execute it.
  :w
  :silent !echo;echo;echo;echo;echo
  :exec ':!mix test '.t:filename

endfunction

autocmd FileType elixir map <buffer> <leader>t :call TestElixir()<cr>
