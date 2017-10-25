function! ToggleRelativeNumber()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

nmap <leader>rn :call ToggleRelativeNumber()<CR>
