" Test the CTRL-P keymapping for LP_formatPythonImport().

" Load the test data.
edit wrap_keymap.in

" The macro is only active when the filetype is python.
"set filetype=python

" Go to the second line and wrap the import.
" Use exe so that we can simulate CTRL-P with '\<C-P>'.
" WARNING: 'exe' requires 'normal' instead of 'normal!'.
exe "set filetype=python | normal ggj\<C-P>"

" Save the processed buffer contents.
" The test framework compares this with the provided test001.ok.
write wrap_keymap.out

" Exit VIM so that the test result is evaluated.
quit!
