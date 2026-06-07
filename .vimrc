call plug#begin()
Plug 'jparise/vim-graphql'
Plug 'derekwyatt/vim-scala'
Plug 'fatih/vim-go'
Plug 'vim-test/vim-test'

" Native Neovim LSP tooling. Mason keeps language servers declared and
" installed from this config instead of scattered global npm/go/gem installs.
Plug 'neovim/nvim-lspconfig'
Plug 'saghen/blink.cmp', { 'tag': 'v1.*' }
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'

Plug 'morhetz/gruvbox'

" Vim Polyglot should load after language specific plugins.
Plug 'sheerun/vim-polyglot'

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
Plug 'AndrewRadev/splitjoin.vim'

Plug 'reedes/vim-pencil'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'hwartig/vim-seeing-is-believing'

" Additional text objects.
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-line'

Plug 'rhysd/vim-textobj-ruby'

Plug 'ngmy/vim-rubocop'

Plug 'bling/vim-airline'

Plug 'GEverding/vim-hocon'

Plug 'knubie/vim-kitty-navigator', {'do': 'cp ./*.py ~/.config/kitty/'}

Plug 'tpope/vim-vinegar' " Additions to the built-in netrw directory browser.
call plug#end()

lua << EOF
local blink_ok, blink = pcall(require, "blink.cmp")
if blink_ok then
  blink.setup({
    keymap = {
      preset = "super-tab",
      -- Kitty owns <C-n>/<C-p> for tab navigation. Use <C-j>/<C-k> for
      -- completion menu movement instead; in normal mode these remain kitty
      -- navigator pane movement mappings.
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = false,
      ["<C-p>"] = false,
    },
    completion = {
      documentation = { auto_show = false },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
    },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  })
end

local mason_ok, mason = pcall(require, "mason")
if mason_ok then
  mason.setup()
end

local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lsp_ok then
  mason_lspconfig.setup({
    ensure_installed = {
      "gopls",
      "pyright",
      "ts_ls",
    },
    automatic_enable = true,
  })
end

local tools_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if tools_ok then
  mason_tool_installer.setup({
    ensure_installed = {
      "prettier",
    },
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>qf", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]g", vim.diagnostic.goto_next, opts)
  end,
})

vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, {})
EOF

set shell=/bin/sh
set nocompatible
runtime macros/matchit.vim

" Properly set the window title.
set title
let &titlestring='nvim'

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

set hlsearch " Highlight searches.
set relativenumber " Relative line numbering...
set number " with the current line number being absolute.
set cursorline " Highlight the current line.
set signcolumn=yes
set completeopt=menuone,noselect,popup
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
" Copy the current file path and line number.
nnoremap <leader>yl :let @+=expand('%') . ':' . line('.')<CR>
" Copy the current file path and selected line range.
xnoremap <leader>yl :<C-U>let @+=expand('%') . ':' . min([line("'<"), line("'>")]) . '-' . max([line("'<"), line("'>")])<CR>

" Paste that doesn't replace the default register.
vnoremap <leader>p "_dP

" Upcase the current word in normal mode.
nnoremap <leader>u viwU

" routes.rb and Gemfile
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>
map <leader>gd :topleft 100 :split config/database.yml<cr>
" Command-Dash to split screen
map <leader>v :vsplit<ESC><C-w><C-w>
map <leader>s :split<ESC><C-w><C-w>
" Visually select the text that was last edited/pasted (compare to gv)
nmap gV `[v`]
" Goto File Horizontal and Vertical Splits
map gfv <C-w>L
map gfs <C-w>f

" FZF Configuration
set rtp+=/opt/homebrew/opt/fzf
map <leader>f :GFiles<CR>
map <leader>b :Buffers<CR>
map <leader>cf :BCommits<CR>
map <leader>lf :BLines<CR>
map <leader>mf :Marks<CR>
map <leader>df :Files<CR>

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

" Disable code folding
set nofoldenable

" SplitJoin
nmap sj :SplitjoinSplit<cr>
nmap sk :SplitjoinJoin<cr>

" vim-markdown Configuration
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_frontmatter=1

" Limelight Configuration
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_paragraph_span = 1
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Configure Ruby Indentation
let g:ruby_indent_block_style = 'do'

" Seeing Is Believing Configuration
augroup seeingIsBelievingSettings
  autocmd!

  autocmd FileType ruby nmap <buffer> <leader>r <Plug>(seeing-is-believing-mark-and-run)
  autocmd FileType ruby xmap <buffer> <leader>r <Plug>(seeing-is-believing-mark-and-run)
augroup END

" Enable filetype detection.
filetype plugin indent on

" Syntax and Colors
syntax enable
let g:gruvbox_contrast_dark = 'soft'
set background=dark    " Setting dark mode
autocmd vimenter * colorscheme gruvbox
autocmd vimenter * highlight Normal ctermbg=NONE
