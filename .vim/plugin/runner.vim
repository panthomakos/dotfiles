function! RunLine(line)
  let command=substitute(getline(a:line), '"', '\\"', 'g')
  let command="pry --no-color -e \"".command."\" -e 'exit'"

  " Execute the command and output the result.
  let output=substitute(system(command), "[0G", "", "g")
  let output = substitute(output, "[\]\|[[:cntrl:]]", '\r', "g")

  let results=split(output, '\r')
  let addition=a:line

  for result in range(0,len(results)-1)
    if match(results[result], '^=>') != -1 || addition > a:line
      let newline=substitute(getline(a:line), '\(\s\+# => .*\)\=$', ' # '.results[result], 'v')
      call setline(addition, newline)
      let addition=addition+1
    end
  endfor
endfunction

function! RunLines() range
  for line in range(a:firstline, a:lastline)
    if (match(getline(line), '^\s*$') == -1)
      call RunLine(line)
    end
  endfor
endfunction

map <leader>r :call RunLines()<cr>
map <leader>R :exec 0.','.line('$') 'call RunLines()'<cr>
