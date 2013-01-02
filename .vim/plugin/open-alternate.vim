" Open test or production code file depending on context.
"
" * When in a test file, open the production code.
" * When in a production file, open the test code.

function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction

function! AlternateForCurrentFile()
  let current_file = expand('%')
  let new_file = current_file

  let in_spec = match(current_file, '^spec/') != -1
  let in_test = match(current_file, '^test/') != -1

  let in_controllers = match(current_file, '\<controllers\>') != -1
  let in_models = match(current_file, '\<models\>') != -1
  let in_views = match(current_file, '\<views\>') != -1
  let in_workers = match(current_file, '\<workers\>') != -1

  let in_app = in_controllers || in_models || in_views || in_workers

  if in_spec || in_test
    if in_spec
      let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
      let new_file = substitute(new_file, '^spec/', '', '')
    elseif in_test
      let new_file = substitute(new_file, '_test\.rb$', '.rb', '')
      let new_file = substitute(new_file, '^test/', '', '')
    end

    if in_app
      let new_file = 'app/' . new_file
    end

    return new_file
  else
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end

    let spec_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let spec_file = 'spec/' . spec_file

    let test_file = substitute(new_file, '\.rb$', '_test.rb', '')
    let test_file = 'test/' . test_file

    if filereadable(test_file)
      return test_file
    else
      return spec_file
    end
  end
endfunction

nnoremap <leader>. :call OpenTestAlternate()<cr>

