au BufEnter *.hs compiler ghc
autocmd FileType haskell let &formatprg="stylish-haskell"
