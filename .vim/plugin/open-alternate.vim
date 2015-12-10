" Open test or production code file depending on context.
"
" * When in a test file, open the production code.
" * When in a production file, open the test code.

function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction

function SpecFileName(name)
  return 'spec/' . substitute(a:name, '\.rb$', '_spec.rb', '')
endfunction

function TestFileName(name)
  return 'test/' . substitute(a:name, '\.rb$', '_test.rb', '')
endfunction

function! AlternateForCurrentFile()
  let current_file = expand('%')
  let new_file = current_file

  let in_spec = match(current_file, '^spec/') != -1
  let in_test = match(current_file, '^test/') != -1

  let app_directories = [ 'controllers', 'models', 'views', 'workers' ]

  let in_app = 0

  for dir in app_directories
    let in_app = in_app || match(current_file, '\<' . dir . '\>') != -1
  endfor

  let files = []

  if in_spec || in_test
    if in_spec
      let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
      let new_file = substitute(new_file, '^spec/', '', '')
    elseif in_test
      let new_file = substitute(new_file, '_test\.rb$', '.rb', '')
      let new_file = substitute(new_file, '^test/', '', '')
    end

    call add(files, new_file)

    if in_app
      call add(files, 'app/' . new_file)
    end

    call add(files, 'lib/' . new_file)
  else
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end

    let files = []

    call add(files, SpecFileName(new_file))
    call add(files, TestFileName(new_file))

    let new_file = substitute(new_file, '^lib/', '', '')

    call add(files, SpecFileName(new_file))
    call add(files, TestFileName(new_file))
  end

  for file in files
    if filereadable(file)
      return file
    endif
  endfor
endfunction

nnoremap <leader>. :call OpenTestAlternate()<cr>

