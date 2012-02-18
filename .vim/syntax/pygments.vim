" pygments.vim: Vim syntax file for Pygments
" Language:>Markdown
" Maintainer:>Pan Thomakos
" Last Change: 2012 Feb 17
" Version: 0.1

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

ru! syntax/markdown.vim

unlet b:current_syntax


syn region pygmentsHighlight start="{%\s\+highlight\s\+.*%}" end="{%\s\+endhighlight\s\+%}"

hi link pygmentsHighlight Delimiter

let b:current_syntax="pygments"
