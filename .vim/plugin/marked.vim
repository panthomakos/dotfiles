" Render current Buffer in Markdown and open in Chromium
function! MarkdownOpen()
  let l:filename = expand("%:p")
  let l:directory = expand("%:h")
  let l:output = l:directory."/markdown.tmp"
  silent exe "!markdown ".l:filename." > ".l:output
  silent exe "!chromium ".l:output
  silent exe "!rm ".l:output
  redraw!
endfunction

map <leader>m :call MarkdownOpen()<CR>
