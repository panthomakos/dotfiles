" Render current Buffer in Markdown and open in Chromium
function! MarkdownOpen()
  let l:filename = expand("%:p")
  let l:output = "/tmp/markdown-preview.html"
  silent exe "!grip ".l:filename." --export ".l:output
  silent exe "!google-chrome-stable ".l:output
  redraw!
endfunction

map <leader>m :call MarkdownOpen()<CR>
