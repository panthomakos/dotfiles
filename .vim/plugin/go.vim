autocmd FileType go nnoremap <buffer> <leader>i :GoImports<CR>
autocmd FileType go nnoremap <buffer> <leader>t :GoTest<CR>
autocmd FileType go nnoremap <buffer> <leader>r :GoRun<CR>

command! -nargs=+ Goggrep :Ggrep <args> -- ':!^vendor/'
