
runtime canonical-vim/share/python_import_macros.vim

autocmd FileType python map <C-L> :python LP_python_import_search()
autocmd FileType doctest map <C-L> :python LP_python_import_search()
