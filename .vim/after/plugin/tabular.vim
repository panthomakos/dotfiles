AddTabularPipeline! comma_first_list /^\s\{-1,},\?\s*\zs[a-zA-Z]/
  \ map(a:lines, "substitute(v:val, '\^\\s\\+', '    ', '')")
  \   | tabular#TabularizeStrings(a:lines, '^\s\{-1,},\?\s*\zs[a-zA-Z]', 'r1c0l0')
