" The .css.THIS and .css.OTHER extensions are created when bzr has
" conflicts merging branches.
autocmd BufRead,BufNewFile *.css,*.css.THIS,*.css.OTHER setf css
