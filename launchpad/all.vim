" Load all the launchpad .vim files.
"
" This file expects to be located at
" $HOME/.vim/canonical-vim/launchpad/all.vim
" although it can be in another directory besides $HOME/.vim that is in
" vim's runtimepath.

" Enable vim to find the canonical-vim/launchpad/ftdetect directory
" for filetype specific configurations.
let $extra_rtp=globpath(&runtimepath, 'canonical-vim') . "/launchpad"
set runtimepath+=$extra_rtp

" Turn filetype off so that it will check the new runtimepath when it
" is re-enabled in standard.vim.
filetype off

runtime canonical-vim/launchpad/standard.vim
runtime canonical-vim/launchpad/optional/python_fold_indent.vim
runtime canonical-vim/launchpad/optional/python_ctrl_space_autocomplete.vim
runtime canonical-vim/launchpad/optional/python_ctrl_p_format_import.vim
runtime canonical-vim/launchpad/optional/python_ctrl_l_auto_import.vim
runtime canonical-vim/launchpad/optional/shift_t_wrap_paragraph.vim
runtime canonical-vim/launchpad/optional/fix_highlighting.vim
runtime canonical-vim/launchpad/optional/disable_annoying_features.vim
