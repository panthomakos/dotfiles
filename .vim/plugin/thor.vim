if has("autocmd")
  filetype on

  autocmd BufNewFile,BufRead *.thor setfiletype ruby
end
