" Load all the personal .vim files.
"
" This file expects to be located at
" $HOME/.vim/vim-config/personal/all.vim
" although it can be in another directory besides $HOME/.vim that is in
" vim's runtimepath.

" Enable vim to find the vim-config/personal/ftdetect directory
" for filetype specific configurations.
let $extra_rtp=globpath(&runtimepath, 'vim-config') . "/personal"
set runtimepath+=$extra_rtp

" Turn filetype off so that it will check the new runtimepath when it
" is re-enabled in standard.vim.
filetype off

runtime vim-config/personal/standard.vim
runtime vim-config/personal/optional/python_fold_indent.vim
runtime vim-config/personal/optional/python_ctrl_space_autocomplete.vim
runtime vim-config/personal/optional/python_ctrl_p_format_import.vim
runtime vim-config/personal/optional/python_ctrl_l_auto_import.vim
runtime vim-config/personal/optional/shift_t_wrap_paragraph.vim
runtime vim-config/personal/optional/fix_highlighting.vim
runtime vim-config/personal/optional/disable_annoying_features.vim
