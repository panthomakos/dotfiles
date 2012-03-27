" Move to previous and next tag
map [t :tp<cr>
map ]t :tn<cr>

command! RubyTag :!ctags -R --languages=ruby

autocmd BufWritePost *.rb
      \ if filereadable('tags') |
      \   call system('ctags -a '.expand('%')) |
      \ endif

