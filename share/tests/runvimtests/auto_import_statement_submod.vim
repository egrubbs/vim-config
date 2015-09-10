" Test that LP_python_import_search() import statement contains
" 'from submod' and not 'from submod.__init__', which is amazingly ugly.

" Load the test data.
edit auto_import_statement_submod.in

" Go to the first line and add an import statement for SubMod().
normal! gg

" Make sure vim can find the tags file for the tests.
let tag_file = expand('%:p:h') . '/data/tags'
exe 'set tags=' . tag_file

python << EOF
def LP_inputlist(options):
    return 1

LP_python_import_search()
EOF

" Save the processed buffer contents.
" The test framework compares this with the provided
" auto_import_statement_submod.ok.
write auto_import_statement_submod.out

" Exit VIM so that the test result is evaluated.
quit!
