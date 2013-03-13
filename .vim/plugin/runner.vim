function! RunLine(line)
  " Replace any existing output comments on the current line.
  let newline=substitute(getline(a:line), '\(\s\+# =>\s*.*\)\=$', '', 'v')
  call setline(a:line, newline)

  " Parse the line and generate a pry command.
  let command=substitute(getline(a:line), '"', '\\"', 'g')
  let command="pry --no-color -e \"".command."\" -e 'exit'"

  " Substitute odd characters in the output.
  let output=substitute(system(command), "[0G", "", "g")
  let output=substitute(output, "[[:cntrl:]]", '\r', "g")

  " Split the output up by line.
  let lines=split(output, '\r')

  let results=[]
  for result in range(0,len(lines)-1)
    " Only capture hash-rocket lines or lines following the hash-rocket.
    if match(lines[result], '^=>') != -1 || len(results) > 0
      " Ignore empty lines.
      if match(lines[result], '^\s*$') == -1
        call add(results, lines[result])
      end
    end
  endfor

  " Remove any result lines after the current line.
  while match(getline(a:line + 1), '^\s*#\s.*') != -1
    exec (a:line+1).'delete'
  endwhile

  " Loop through the results and append them to the file.
  for result in range(0,len(results)-1)
    if result == 0 " Append the first result to the current line.
      let newline=substitute(getline(a:line), '$', ' # '.results[result], 'v')
      call setline(a:line, newline)
    else " Add every additional result line after the current line.
      call append(a:line+result-1, '# '.results[result])
    end
  endfor
endfunction

function! RunLines() range
  " Loop through the range and execute each line.
  for line in range(a:firstline, a:lastline)
    if (match(getline(line), '^\s*$') == -1)
      call RunLine(line)
    end
  endfor
endfunction

map <leader>r :call RunLines()<cr>
map <leader>R :exec 0.','.line('$') 'call RunLines()'<cr>
