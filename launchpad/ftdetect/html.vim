" The .THIS and .OTHER extensions are created when bzr has
" conflicts merging branches.

autocmd BufRead,BufNewFile *.jinja,*.jinja.THIS,*.jinja.OTHER setf htmldjango
autocmd BufRead,BufNewFile *.html,*.html.THIS,*.html.OTHER setf htmldjango
autocmd BufRead,BufNewFile *.htm,*.htm.THIS,*.htm.OTHER setf html

autocmd BufRead,BufNewFile *.hbs,*.hbs.THIS,*.hbs.OTHER setf html

" Zope templates are treated as html files.
autocmd BufRead,BufNewFile *.pt,*.pt.THIS,*.pt.OTHER setf html
