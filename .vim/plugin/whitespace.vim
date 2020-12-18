function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

map <D-5> :call <SID>StripTrailingWhitespaces()<CR>

if has("autocmd")
  autocmd BufWritePre *.js,*.rb,*.thor,*.ts,*.rake,*.haml,*.scala :call <SID>StripTrailingWhitespaces()
  autocmd BufWritePre *.hs :call <SID>StripTrailingWhitespaces()
endif
