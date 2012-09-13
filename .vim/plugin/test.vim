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
    if t:rails
      let t:command=t:command.' --drb'
    end
  elseif match(t:filename, '_test\.rb$') != -1
    let t:command='ruby'
  elseif match(t:filename, '\.coffee$') != -1
    let t:command='jasmine-headless-webkit --no-full-fun'
  elseif match(t:filename, '\.feature$') != -1
    let t:command='cucumber'
  end

  " Check if we are using bundler.
  if filereadable('Gemfile')
    let t:command='bundle exec '.t:command
  end

  let t:command='RAILS_ENV=test '.t:command
endfunction

function! RunTestFile(...)
  if match(expand('%'), '\(.feature\|_spec.rb\|_test.rb\|Spec.coffee\)$') != -1
    call SetTestFile()
  end

  call RunTests()
endfunction

map <leader>t :call RunTestFile()<cr>
