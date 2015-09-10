" (list) Show invisible characters.
" (listchars lcs) Override how invisible characters are shown:
"   tab:>~      A tab character takes up multiple spaces. Display '>' for the
"               first space and '~' for all the following spaces.
"   trail:*     Display '*' for spaces at the end of the line.
setlocal list listchars=tab:>~,trail:*

" (match mat) Find text matching the expression, and highlight it with
" the colors defined for the Error group.
"   '\%>78v.\+'     Match any character past the 78th column.
"   '\|'            Or
"   ' \+$'          Match spaces at the end of the line.
match Error /\%>78v.\+\| \+$/

" (fo) Only autowrap comments to textwidth, i.e. remove 't' from formatoptions,
" which defaults to 'tcq'. Autowrapping code is problematic.
setlocal formatoptions=cq
