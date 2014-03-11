augroup filetype_ruby
  autocmd!
  " Create an RSpec `it '' do <CR> end` block and enter insert mode between
  " the cursors.
  autocmd FileType ruby :inoreabbrev <buffer> itt it '' do<cr>end<esc>kf'a<C-R>=Eatchar('\s')<cr>
  " Create a ruby function block and enter insert mode after the `def`.
  autocmd FileType ruby :inoreabbrev <buffer> deff def<cr>end<esc>kA
augroup END
