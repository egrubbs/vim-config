" The .zcml.THIS and .zcml.OTHER extensions are created when bzr has
" conflicts merging branches.
autocmd BufRead,BufNewFile *.zcml,*.zcml.THIS,*.zcml.OTHER setf xml
