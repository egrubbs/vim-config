" Test LP_format_python_import()

" Load the test data.
edit wrap_3to3.in

" The macro is only active when the filetype is python.
set filetype=python

" Go to the first line and wrap the import with '^P'.
normal! gg
python LP_format_python_import()

" Save the processed buffer contents.
" The test framework compares this with the provided test001.ok.
write wrap_3to3.out

" Exit VIM so that the test result is evaluated.
quit!
