" Set listchars for tabs and trailing spaces.
setlocal listchars=tab:>-,trail:- 
setlocal list

setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

execute "setlocal colorcolumn=" . join(range(101,999),',')
