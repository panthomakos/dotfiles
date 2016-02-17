" Open test or production code file depending on context.
"
" * When in a test file, open the production code.
" * When in a production file, open the test code.

function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction

function TestFileNamePrefix(name, type)
  let bname = fnamemodify(a:name, ':t')
  let hdir = fnamemodify(a:name, ':h')
  return a:type . '/' . hdir . '/' . a:type . '_' . bname
endfunction

function TestFileNameSuffix(name, type)
  return a:type . '/' . substitute(a:name, '\.rb$', '_' . a:type . '.rb', '')
endfunction

function! AlternateForCurrentFile()
  let current_file = expand('%')
  let new_file = current_file

  if isdirectory('spec')
    let prefix = 'spec'
  else
    let prefix = 'test'
  endif

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
      let new_file = substitute(new_file, '/test_', '/', '')
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

    if prefix == 'spec'
      call add(files, TestFileNameSuffix(new_file, prefix))
    elseif prefix == 'test'
      call add(files, TestFileNamePrefix(new_file, prefix))
      call add(files, TestFileNameSuffix(new_file, prefix))
    end

    let new_file = substitute(new_file, '^lib/', '', '')

    if prefix == 'spec'
      call add(files, TestFileNameSuffix(new_file, prefix))
    elseif
      call add(files, TestFileNamePrefix(new_file, prefix))
      call add(files, TestFileNameSuffix(new_file, prefix))
    end
  end

  for file in files
    if filereadable(file)
      return file
    endif
  endfor

  return files[0] " If the file does not yet exist, return the first one.
endfunction

nnoremap <leader>. :call OpenTestAlternate()<cr>

