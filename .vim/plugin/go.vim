let test#go#runner='gotest'
let test#strategy='kitty'

autocmd FileType go nnoremap <buffer> <leader>i :GoImports<CR>
autocmd FileType go nnoremap <buffer> <leader>t :TestFile<CR>
autocmd FileType go nnoremap <buffer> <leader>r :GoRun<CR>

command! -nargs=+ Goggrep :Ggrep <args> -- ':!^vendor/'
