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
  let going_to_spec = !in_spec
  let in_controllers = match(current_file, '\<controllers\>') != -1
  let in_models = match(current_file, '\<models\>') != -1
  let in_views = match(current_file, '\<views\>') != -1
  let in_app = in_controllers || in_models || in_views

  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    end
  end
  return new_file
endfunction

nnoremap <leader>. :call OpenTestAlternate()<cr>

