autocmd FileType c map <buffer> <leader>ac :Tabularize /\/\*/<cr>
autocmd FileType ruby,yaml map <buffer> <leader>ac :Tabularize /#/<cr>

nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a, :Tabularize /[^,],\zs<CR>
vmap <Leader>a, :Tabularize /[^,],\zs<CR>
