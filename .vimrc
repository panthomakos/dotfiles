call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set shell=/bin/sh
set nocompatible
runtime macros/matchit.vim

" Help break the habit of using arrow keys.
noremap  <up> <nop>
inoremap <up> <nop>
vnoremap <up> <nop>
noremap  <down> <nop>
inoremap <down> <nop>
vnoremap <down> <nop>
noremap  <left> <nop>
inoremap <left> <nop>
vnoremap <left> <nop>
noremap  <right> <nop>
inoremap <right> <nop>
vnoremap <right> <nop>

""""""""""
" Settings
""""""""""
" Use proper clipboard
set clipboard=unnamed
" Make backspace work properly.
set backspace=2
" Configure status line.
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2
" Automatic window sizing.
set winwidth=84
set winheight=5
set winminheight=5
set winheight=999
" Tabs
set ts=2 sts=2 sw=2 expandtab
" Show tabs and trailing spaces
set listchars=tab:>-,trail:-
set list
set hlsearch " Highlight searches.
set number " Number lines.
set cursorline " Highlight the current line.
set ignorecase " Make searches case insensitive.
set smartcase " Make searches case-sensitive if they contain upper-case.
set formatprg=par " Use par as the format program.
" Wildignore - files we don't want to find/search.
set wildignore+=*.rbc,*/doc/*,*/spec/cassettes/*,tags,*/junit/*
" Set spelling region to English
set spelllang=en

command! Markdown :!ronn --html %

""""""""""""""""""""""""""
" Convenience Key Mappings
""""""""""""""""""""""""""
" Leader
let mapleader=','
" Switch between two files
nnoremap <leader><leader> <c-^>
" Edit files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
" Insert a hash rocket.
imap <c-l> <space>=><space>
" Clear the search buffer.
nnoremap <cr> :nohlsearch<cr>
" Toggle spell-check.
nmap <silent> <leader>sp :set spell!<CR>
" Quickly edit vimrc.
nmap <leader>vi :tabedit $MYVIMRC<CR>
" Move in viewports
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
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
" Access CtrlP
map <leader>f :CtrlP<CR>
" Reload CtlrP Cache.
map <leader>cf :CtrlPClearCache<CR>\|:CtrlP<CR>

" Enable filetype detection.
filetype plugin indent on

" Syntax and Colors.
set t_Co=256
syntax enable
set background=dark
color grb256
