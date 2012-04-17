" Highlight lines that are longer than 80 characters.
highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
au BufWinEnter,VimEnter,WinEnter * let w:m1=matchadd('OverLength', '\%>80v.\+', -1)
