autocmd FileType ruby nmap <buffer> <leader>gcl gg:call search('^\s*class .*')<CR>
autocmd FileType ruby nmap <buffer> <leader>gin gg:call search('def init.*')<CR>
autocmd FileType ruby nmap <buffer> <leader>gde gg:call search('describe .*')<CR>
