" This function allows us to consume any characters typed after an
" abbreviation. See `:helpgrep Eatchar` for more details.
func Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

