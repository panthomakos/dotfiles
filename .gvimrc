if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  " Command-Return for fullscreen
  macmenu Window.Toggle\ Full\ Screen\ Mode key=<D-CR>

  " Command-Shift-F for Ack
  map <D-F> :Ack<space>

  " Adjust viewports to the same size
  map <Leader>= <C-w>=
  imap <Leader>= <Esc> <C-w>=

  " Unbind macvim keybindings
  macm File.New\ Tab key=<nop>
  macm File.Close key=<nop>
  macm File.Close\ Window key=<nop>
  macm Tools.List\ Errors key=<nop>
  macm File.Save key=<nop>

  " Move in tabs
  inoremap <D-l> <esc>gt
  inoremap <D-h> <esc>gT
  noremap <D-l> gt
  noremap <D-h> gT

  " Start without the toolbar
  set guioptions-=T
endif


