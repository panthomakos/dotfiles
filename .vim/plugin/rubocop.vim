" Run RuboCop on the entire project and load errors into the quickfix list.
function! RuboCopAll()
  :exec ":cexpr system('bundle exec rubocop -P --format emacs')"
endfunction
