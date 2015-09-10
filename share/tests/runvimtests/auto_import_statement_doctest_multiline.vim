" Test LP_python_import_search().

" Load the test data.
edit auto_import_statement_doctest_multiline.in

" Move the cursor to the alpha() and add an import statement for it.
call search('alpha')

" Make sure vim can find the tags file for the tests.
let tag_file = expand('%:p:h') . '/data/tags'
exe 'set tags=' . tag_file

" Set filetype to doctest.
set filetype=doctest

python << EOF
import vim

def LP_inputlist(options):
    return 2

LP_python_import_search()
EOF

" Save the processed buffer contents.
" The test framework compares this with the provided
" auto_import_statement_doctest_multiline.ok.
write auto_import_statement_doctest_multiline.out

" Exit VIM so that the test result is evaluated.
quit!
