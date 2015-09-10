" The .py.THIS and .py.OTHER extensions are created when bzr has
" conflicts merging branches.
autocmd BufRead,BufNewFile *.py,*.py.THIS,*.py.OTHER setf python
