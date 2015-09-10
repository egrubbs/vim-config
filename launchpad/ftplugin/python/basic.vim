" Based on https://dev.launchpad.net/UltimateVimPythonSetup

" Change indent after an open paren to the same as the shiftwidth
" instead of twice the shiftwidth. This variable depends on
" :filetype indent on
" See /usr/share/vim/vim72/doc/indent.txt
let g:pyindent_open_paren = '&sw'

" More syntax highlighting.
" See /usr/share/vim/vim72/syntax/python.vim
let python_highlight_all = 1

" Common configs for python, javascript, and css files.
runtime canonical-vim/launchpad/ftplugin/_common.vim

" Depends on the matchit.vim plugin. When a python file is loaded,
" the '%' key can be used to jump between matching if/elif/else and try/except
" statements in addition to matching parens, braces, and brackets.
runtime canonical-vim/share/python_match.vim

" ***** UNNECESSARY ******
" Already configured by
" :filetype plugin indent on
" which is set in the standard.vim

" (ai) Indent a new line the same as the previous line. vim help
" recommends it with smartindent, but it doesn't seem to change anything
" if smartindent is on.
"set autoindent

" (si) Smart indenting automatically increases the indent on a line following
" a keyword listed in cinwords.
"set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
