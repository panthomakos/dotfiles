" Highlight lines that are longer than 80 characters.
function ToggleOverLength()
  if exists('b:overlength') && b:overlength
    highlight clear OverLength
    let b:overlength = 0
  else
    call EnableOverLength()
  end
endfunction

function EnableOverLength()
  highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
  match OverLength /\%81v.\+/
  let b:overlength = 1
endfunction

map <leader>co :call ToggleOverLength()<cr>
au BufWinEnter * call EnableOverLength()
