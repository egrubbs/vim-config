" This file is for features that some people may find annoying,
" therefore, it is completely optional.

" Do not highlight a matching paren when the cursor is over a paren.
" This is different from the 'showmatch' config that only blinks the
" matching open paren when the closing paren is typed.
" Setting the loaded_matchparen variable prevents the matchparen plugin
" from loading, since it thinks it has already been loaded. If you
" want to re-enable it temporarily without changing your config and
" restarting vim, you can use these commands:
" :unlet loaded_matchparen
" :runtime plugin/matchparen.vim
let loaded_matchparen=1
