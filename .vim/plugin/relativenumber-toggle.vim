function! ToggleRelativeNumber()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

nmap <leader>ln :call ToggleRelativeNumber()<CR>
