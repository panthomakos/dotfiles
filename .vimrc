call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set shell=/bin/sh
set nocompatible
runtime macros/matchit.vim

" Use proper clipboard
set clipboard=unnamed

" Make backspace work properly
set backspace=2

" Fugitive
autocmd BufReadPost fugitive://* set bufhidden=delete
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2

" Preview Window Height
set previewheight=15
au BufEnter ?* call PreviewHeightWorkAround()
function! PreviewHeightWorkAround()
    if &previewwindow
        exec 'setlocal winheight='.&previewheight
    endif
endfunc

nnoremap <leader>p :!ronn --html %<CR>

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" Leader
let mapleader=','

" Window sizing
set winwidth=84
set winheight=5
set winminheight=5
set winheight=999

" Switch between two files
nnoremap <leader><leader> <c-^>

" Tabs
set ts=2 sts=2 sw=2 expandtab

" Show tabs and trailing spaces
set listchars=tab:>-,trail:-
set list

" Edit files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" Highlight Search
set hlsearch
map <Leader>k :let @/ = ""<CR>

" Number lines
set number

" Highlight the current line
set cursorline

" Make searches case-sensitive only if they contain upper-case characters
set ignorecase
set smartcase

" Use par as the format program
set formatprg=par

" Set spelling on and off using <leader>s
nmap <silent> <leader>sp :set spell!<CR>

" Automatically source vimrc
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
end

" Wildignore RBC and doc files
set wildignore+=*.rbc,doc/*,spec/cassettes/*

" Quickly edit vimrc
nmap <leader>vi :tabedit $MYVIMRC<CR>

" Set spelling region to English
set spelllang=en

if has("autocmd")
  " Enable filetype detection
  filetype plugin indent on

  " Restore current cursor position
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
endif

set t_Co=256
syntax enable
set background=dark
color grb256

" set t_Co=256
" syntax enable
" set background=dark
" let g:solarized_termcolors=256
" color solarized

" Show syntax highlighting groups for word under cursor
nmap <leader>syn :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Move in viewports
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Faster movement
map fj 20j
map fk 20k
map fh 20h
map fl 20l

" CommandT
map <leader>f :CommandTFlush<CR>\|:CommandT<CR>
let g:CommandTCancelMap=['<ESC>']
let g:CommandTCursorLeftMap=['<Left>']
let g:CommandTBackspaceMap=['<C-h>']

" Testing
function! RunTests(filename)
  " Write the file and run tests for the given filename
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  if match(a:filename, '\.feature$') != -1
    exec ":!bundle exec cucumber " . a:filename
  elseif match(a:filename, '\.coffee$') != -1
    exec ":!jasmine-headless-webkit --no-full-run " . a:filename
  else
    exec ":!~/bin/test " . a:filename
  end
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|Spec.coffee\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

map <leader>t :call RunTestFile()<cr>

" routes.rb and Gemfile
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" Command-Dash to split screen
map <leader>v :vsplit<ESC><C-w><C-w>
map <leader>s :split<ESC><C-w><C-w>

" Visually select the text that was last edited/pasted (compare to gv)
nmap gV `[v`]

" Goto File Horizontal and Vertical Splits
map gfv <C-w>L
map gfs <C-w>f

" Highlight lines that are longer than 80 characters
highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
au BufWinEnter,VimEnter,WinEnter * let w:m1=matchadd('OverLength', '\%>80v.\+', -1)
