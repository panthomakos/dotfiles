" Testing
function! RunTests()
  " Bail if the test file has not been set.
  if !exists("t:filename")
    return
  end

  " Write the current file, then run the test file.
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent exec ':!echo '.t:command." ".t:filename
  :exec ':!'.t:command." ".t:filename
endfunction

function! SetTestFile()
  " Set the spec file.
  let t:filename=@%

  " Determine if the spec file requires rails.
  let t:rails=(match(getline(1,'$'), 'require\s\+.spec_helper.') != -1)

  " Determine the command required to run the test file.
  if match(t:filename, '_spec\.rb$') != -1
    let t:command='rspec --color'
  elseif match(t:filename, '_test\.rb$') != -1
    let t:command='ruby -Ilib'
  elseif match(t:filename, '\.coffee$') != -1
    let t:command='jasmine-headless-webkit --no-full-fun'
  elseif match(t:filename, '\.feature$') != -1
    let t:command='cucumber'
  end

  " Determine if Zeus is active and running.
  let t:zeus=0

  " We only care if zeus is running when the test requires Rails.
  if t:rails
    let t:zeus=!empty(glob('.zeus.sock'))
  end

  if t:zeus
    let t:command='zeus '.t:command
  else
    if filereadable('Gemfile')
      let t:command='bundle exec '.t:command
    end

    if t:rails
      let t:command='RAILS_ENV=test '.t:command
    end
  end

  let t:command='TZ=UTC '.t:command

  " Check if this is a ./env project.
  if !empty(glob('env'))
    let t:command='./env test'
  endif
endfunction

function! RunRubyTestFile(...)
  if match(expand('%'), '\(.feature\|_spec.rb\|_test.rb\|Spec.coffee\)$') != -1
    call SetTestFile()
  end

  call RunTests()
endfunction

autocmd FileType ruby map <buffer> <leader>t :call RunRubyTestFile()<cr>
