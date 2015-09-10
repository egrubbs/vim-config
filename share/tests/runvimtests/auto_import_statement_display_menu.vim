" Test LP_python_import_search().

" Load the test data.
edit auto_import_statement_display_menu.in

" Go to the first line and find out what import statement are available
" for alpha().
normal! gg

" Make sure vim can find the tags file for the tests.
let tag_file = expand('%:p:h') . '/data/tags'
exe 'set tags=' . tag_file

python << EOF
import vim

def LP_inputlist(options):
    # Append menu to file, so we can test what it looks like.
    # buffer[-1:-1]=foo would actually insert one line above the end of the
    # file, so len() is used instead.
    i = len(vim.current.buffer)
    vim.current.buffer[i:i] = options
    return 0

LP_python_import_search()
EOF

" Save the processed buffer contents.
" The test framework compares this with the provided
" auto_import_statement_display_menu.ok.
write auto_import_statement_display_menu.out

" Exit VIM so that the test result is evaluated.
quit!
