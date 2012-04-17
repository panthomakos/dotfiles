" Automatically set the preview window height.
set previewheight=15

au BufEnter ?* call PreviewHeightWorkAround()

function! PreviewHeightWorkAround()
  if &previewwindow
    exec 'setlocal winheight='.&previewheight
  endif
endfunc

