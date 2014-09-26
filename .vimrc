" Use pathogen to manage all of my bundled plugins.
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set shell=/bin/sh
set nocompatible
runtime macros/matchit.vim

" The arrow keys suck. Don't let them do anything.
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

" Use the system clipboard.
set clipboard=unnamed,unnamedplus

" The default vim backspace options are a little lacking. This makes backspace
" work over the following in insert mode:
"
"   * line breaks (eol)
"   * automatically inserted indentation (indent)
"   * the start of insert mode (start)
set backspace=2

" Status Line Display
set statusline =
" Path to the file (relative to the current directory). Also use %< to
" truncate off the front of the path/file when the line is too long.
set statusline +=%<%f
set statusline +=\ %h " A space, followed by the help buffer flag.
set statusline +=%m " Modifiable flag.
set statusline +=%r " Read Only flag.
set statusline +=%{fugitive#statusline()} " Git status line.
set statusline +=%= " Separation between left and right status lines.
" <line>,<column><virtual column>
" This is left justified with a minimum width of 14.
set statusline +=%-14.(%l,%c%V%)
set statusline +=\ %P " A space, followed by the percentage through the file.

set laststatus=2 " The last window will always have a status line.

" In split mode, make the current window big, but leave others for context.
set winwidth=84
" This is an oddity of vim. We have to set winheight bigger than we want to
" set winminheight. If we set winheight to be huge, before winminheight, then
" winminheight set will fail.
set winheight=5
set winminheight=5
set winheight=999

" Default <Tab> Configuration
set tabstop=2 " Display <Tab> as two spaces in visual mode.
set softtabstop=2 " Insert <Tab> as two spaces when editing.
set shiftwidth=2 " Insert <Tab> as two spaces when auto-indenting.
set expandtab " In insert mode, use the appropriate number of spaes for <Tab>.

set hlsearch " Highlight searches.
set number " Number lines.
set cursorline " Highlight the current line.
set ignorecase " Make searches case insensitive.
set smartcase " Make searches case-sensitive if they contain upper-case.
set formatprg=par " Use par as the format program.

" Wildignore - files we don't want to find/search using CtrlP.
set wildignore+=*.rbc,*/doc/*,*/spec/cassettes/*,tags,*/junit/*

set spelllang=en " Set spelling region to English.

""""""""""""""""""""""""""
" Convenience Key Mappings
""""""""""""""""""""""""""
" Leader
let mapleader=','
" Switch between two files
nnoremap <leader>; <c-^>
" Edit files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
" Insert a hash rocket.
imap <c-l> <space>=><space>
" Clear the search buffer.
nnoremap <space> :nohlsearch<CR>
" Toggle spell-check.
nmap <silent> <leader>sp :set spell!<CR>
" Quickly edit vimrc.
nnoremap <leader>ev :tabedit $MYVIMRC<CR>
" Source vimrc.
nnoremap <leader>sv :source $MYVIMRC<CR>
" Move in viewports
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Upcase the current word in normal mode.
nnoremap <leader>u viwU

" Easily exit insert mode.
inoremap jk <esc>
" Break the habbit of using <esc>
inoremap <esc> <nop>

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

" Use Regular Expression mode in CtrlP.
let g:ctrlp_regexp = 1
" Only list version controlled files in CtrlP.
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']

" Enable filetype detection.
filetype plugin indent on

" Syntax and Colors.
set t_Co=256
syntax enable
set background=dark
color grb256
