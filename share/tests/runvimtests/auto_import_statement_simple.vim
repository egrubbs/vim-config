" Test LP_python_import_search().

" Load the test data.
edit auto_import_statement_simple.in

" Go to the first line and add an import statement for alpha().
normal! gg

" Make sure vim can find the tags file for the tests.
let tag_file = expand('%:p:h') . '/data/tags'
exe 'set tags=' . tag_file

python << EOF
def LP_inputlist(options):
    return 2

LP_python_import_search()
EOF

" Save the processed buffer contents.
" The test framework compares this with the provided
" auto_import_statement_simple.ok.
write auto_import_statement_simple.out

" Exit VIM so that the test result is evaluated.
quit!
