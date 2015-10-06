call plug#begin()
Plug 'junegunn/vim-peekaboo'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-abolish'
Plug 'kien/ctrlp.vim'
Plug 'JazzCore/ctrlp-cmatcher', { 'do' : './install.sh' }
Plug 'tpope/vim-repeat'
Plug 'SirVer/ultisnips'
Plug 'Lokaltog/vim-easymotion'
Plug 'rust-lang/rust.vim'

" Additional text objects.
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-line'

Plug 'vim-ruby/vim-ruby'
Plug 'scrooloose/syntastic'
Plug 'ngmy/vim-rubocop'

Plug 'tpope/vim-endwise'
Plug 'bling/vim-airline'
Plug 'rking/ag.vim'
Plug 'fatih/vim-go'

Plug 'GEverding/vim-hocon'
Plug 'chase/vim-ansible-yaml'
Plug 'craigemery/vim-autotag' " Automatically regenerate ctags.
call plug#end()

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

" TODO (check w/ vim-airline)
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
set relativenumber " Relative line numbering...
set number " with the current line number being absolute.
set cursorline " Highlight the current line.
set ignorecase " Make searches case insensitive.
set smartcase " Make searches case-sensitive if they contain upper-case.
set formatprg=par " Use par as the format program.

" Wildignore - files we don't want to find/search.
set wildignore+=*.rbc,*/doc/*,*/spec/cassettes/*,tags,*/junit/*

set spelllang=en " Set spelling region to English.

""""""""""""""""""""""""""
" Convenience Key Mappings
""""""""""""""""""""""""""
" Leader
let mapleader="\<space>"
let maplocalleader=","
" Save the current file
nnoremap <leader>w :w<CR>
" Enter visual line mode
nmap <leader><leader> V
" Skip the stupid command window
map q: :q
" Switch between two files
nnoremap <leader>; <c-^>
" Edit files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
" Clear the search buffer.
nnoremap <leader><CR> :nohlsearch<CR>
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
" Access CtrlPTags
map <leader>tf :CtrlPTag<CR>
" Reload CtlrP Cache.
map <leader>cf :CtrlPClearCache<CR>\|:CtrlP<CR>

" Use AG as the VIM grep command.
set grepprg=ag\ --nogroup\ --nocolor

" Only list version controlled files in CtrlP when possible.
if isdirectory('.git')
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
else
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
end

" Use ctrlp-cmatcher as the CtrlP matcher function.
let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

" Enable filetype detection.
filetype plugin indent on

" Syntax and Colors.
set t_Co=256
syntax enable
set background=dark
color grb256

" Syntastic Configuration
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_ruby_checkers = [ 'mri', 'rubocop' ]
