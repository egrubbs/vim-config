" Test LP_format_python_import().

" Load the test data.
edit wrap_4to1.in

" The macro is only active when the filetype is python.
set filetype=python

" Go to the second line and wrap the import.
normal! ggj
python LP_format_python_import()

" Save the processed buffer contents.
" The test framework compares this with the provided test001.ok.
write wrap_4to1.out

" Exit VIM so that the test result is evaluated.
quit!
