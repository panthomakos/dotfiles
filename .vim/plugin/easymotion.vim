" Replace regular search w/ easymotion search.
map / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" Default next and previous search bindings now use easymotion.
map n <Plug>(easymotion-next)
map N <Plug>(easymotion-prev)

" Use easymotion for hjkl leader motions.
map <leader>h <Plug>(easymotion-linebackward)
map <leader>j <Plug>(easymotion-j)
map <leader>k <Plug>(easymotion-k)
map <leader>l <Plug>(easymotion-lineforward)

" Use smartcase when searching.
let g:EasyMotion_smartcase = 1
" Jump to first match on enter.
let g:EasyMotion_enter_jump_first = 1
