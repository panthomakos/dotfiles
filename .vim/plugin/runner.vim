function! RunLine() range
  let commands=[]

  for line in range(a:firstline, a:lastline)
    let command = getline(line)
    if (match(command, '^\s*$') == -1)
      let command = substitute(command, '"', '\\"', 'g')
      let command = "-e \"".command."\""
      call add(commands, command)
    end
  endfor

  let joined = join(commands, " ")

  let execution="pry --no-color ".joined." -e 'exit'"

  " Execute the command and output the result.
  let output=substitute(system(execution), "[0G", "", "g")
  let output = substitute(output, "[\]\|[[:cntrl:]]", '\r', "g")
  let lines=split(output, '\r')
  for line in range(0,len(lines)-1)
    let lines[line]="  ".lines[line]
  endfor
  exec append(a:lastline, lines)

  " Go back to the original line number.
  exec ":".a:lastline
endfunction

map <leader>r :call RunLine()<cr>
