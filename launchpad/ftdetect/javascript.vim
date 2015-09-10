" The .js.THIS and .js.OTHER extensions are created when bzr has
" conflicts merging branches.
autocmd BufRead,BufNewFile *.js,*.js.THIS,*.js.OTHER setf javascript
