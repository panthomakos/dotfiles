call plug#begin()
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/vim-peekaboo'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-repeat'
Plug 'SirVer/ultisnips'
Plug 'easymotion/vim-easymotion'

Plug 'reedes/vim-pencil'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'w0rp/ale' " Asynchronous Lint Engine

Plug 'hwartig/vim-seeing-is-believing'

" Additional text objects.
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-line'

Plug 'rhysd/vim-textobj-ruby'

Plug 'ngmy/vim-rubocop'

Plug 'tpope/vim-endwise'
Plug 'bling/vim-airline'

Plug 'GEverding/vim-hocon'
Plug 'craigemery/vim-autotag' " Automatically regenerate ctags.

Plug 'tpope/vim-vinegar' " Additions to the built-in netrw directory browser.
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

" FZF Configuration
map <leader>f :GFiles<CR>
map <leader>b :Buffers<CR>
map <leader>c :Tags<CR>
map <leader>cf :BCommits<CR>
map <leader>lf :BLines<CR>
map <leader>mf :Marks<CR>
map <leader>df :Files<CR>

" Ale Configuration
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_set_highlights = 0
nmap <silent> ]g <Plug>(ale_previous_wrap)
nmap <silent> [g <Plug>(ale_next_wrap)

" Unload Buffer Using Ctrl-W
nmap <C-x> :bd<CR>

" Easy Alignment Mappings
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

let g:easy_align_delimiters = { '>': { 'pattern': '->\|>' } }

" Convenient bindings for beginning and end of line.
nnoremap B ^
nnoremap E $

" Use AG as the VIM grep command.
set grepprg=ag\ --nogroup\ --nocolor

" Configure browser for Haskell Doc
let g:haddock_browser = "/usr/bin/chromium"
let g:haddock_browser_callformat = "%s %s"

" Pencil Configuration
let g:pencil#wrapModeDefault = 'soft'
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
augroup END

" vim-markdown Configuration
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_frontmatter=1

" Limelight Configuration
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_paragraph_span = 1
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
nmap <leader>g :Goyo<CR>

" Configure Ruby Indentation
let g:ruby_indent_block_style = 'do'

" Seeing Is Believing Configuration
augroup seeingIsBelievingSettings
  autocmd!

  autocmd FileType ruby nmap <buffer> <leader>r <Plug>(seeing-is-believing-mark-and-run)
  autocmd FileType ruby xmap <buffer> <leader>r <Plug>(seeing-is-believing-mark-and-run)
augroup END

" Enable lazy redrawing for improved performance.
set lazyredraw

" Enable filetype detection.
filetype plugin indent on

" Syntax and Colors.
set t_Co=256
syntax enable
set background=dark
color grb256
