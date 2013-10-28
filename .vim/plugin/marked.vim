" Open current buffer in Marked Application.
function! MarkedOpen()
  let l:filename = expand("%:p")
  silent exe "!open -a Marked.app '".l:filename."'"
  redraw!
endfunction

map <leader>m :call MarkedOpen()<CR>
