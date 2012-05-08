" Highlight lines that are longer than 80 characters.
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
" au BufWinEnter,VimEnter,WinEnter * let w:m1=matchadd('OverLength', '\%>80v.\+', -1)


" set colorcolumn=80

function ToggleOverLength()
  if exists('b:overlength') && b:overlength
    highlight clear OverLength
    let b:overlength = 0
    echo "Overlength highlighting off"
  else
    highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
    match OverLength /\%81v.\+/
    let b:overlength = 1
    echo "Overlength highlighting on"
  end
endfunction

map <leader>co :call ToggleOverLength()<cr>
