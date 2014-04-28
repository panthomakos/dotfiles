" Render current Buffer in Markdown and open in Chromium
function! MarkdownOpen()
  let l:filename = expand("%:p")
  silent exe "!markdown ".l:filename." > markdown.tmp"
  silent exe "!chromium markdown.tmp"
  silent exe "!rm markdown.tmp"
  redraw!
endfunction

map <leader>m :call MarkdownOpen()<CR>
