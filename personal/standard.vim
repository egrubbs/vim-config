" (ai) Indent a new line the same as the previous line. We normally
" always want this, even if the filetype can't be determined. Loading
" the `filetype indent` settings below will override this, if necessary.
" For example, vim72/indent/php.vim will set noautoindent and use its
" own custom functions for indenting.
set autoindent

" Automatically use the plugin and indent settings vim has for the filetype.
" Eliminates the need to set smartindent and cinwords.
" Besides autoindenting, it will do auto-dedenting of keywords such as 'else'.
" It will make SHIFT-k use pydoc when editing a python file.
" See
"   /usr/share/vim/vim72/ftplugin/python.vim
"   /usr/share/vim/vim72/syntax/python.vim
"   /usr/share/vim/vim72/indent/python.vim
filetype plugin indent on

" Where vim will look for ctags files. (See :help tags-option)
" Start in the directory of the file being edited, then start looking in
" its parent directories. Launchpad currently has eleven levels of
" directories. If all else fails, look for the tags file in the CWD.
set tags=./tags,./../tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags,./../../../../../../tags,./../../../../../../../tags,./../../../../../../../../tags,./../../../../../../../../../tags,./../../../../../../../../../../tags,tags

" This is normally on anyways, but we will get errors loading other
" configs if this happens to be off.
syntax on

" Allow setting specific vim options by adding a comment
" to the file containing 'vim:'.
set modeline

" Enable the '%' key to not just jump between matching parens, braces,
" etc., but also jump between matching if/elif/else statements and html tags.
" This is normally configured by the filetype plugin, but matching for
" python is provided by share/python_match.vim, which is loaded by
" personal/python_options.vim.
runtime macros/matchit.vim

" (tw) Point at which the line is wrapped according to formatoptions.
set textwidth=72

"**** Tabs and Indenting. ****
" (ts) Specify how wide a tab-character (not the tab-key) appears.
" If expandtab is on, and there are no tab-characters in the file,
" it has no effect. Some third party python libraries mix tabs and
" spaces for indentation, so it is useful to set this to 8, since
" python considers a tab the same as 8 spaces for indentation.
set tabstop=8

" (sts) Specify how much white space the tab-key inserts and how
" much white space the backspace removes.
set softtabstop=4

" (et) Make the tab key always input spaces.
" If you absolutely need a tab character, enter <CTRL-V>, <Tab>.
set expandtab

" (sw) Specify the indentation for '<<', '>>', and autoindent.
set shiftwidth=4

" (shiftround si) Instead of always shifting shiftwidth spaces,
" ensure that the indentation is a multiple of shiftwidth.
set shiftround

" (sta) Tabs indent according to shiftwidth at beginning of line.
set smarttab

" (incsearch is) While typing the search term, jump to the next
" matching item instead of waiting till the enter key is pressed.
set incsearch

" (showmatch sm) When ')', '}', ']' is entered, briefly highlight
" the matching open paren, brace or bracket.
set showmatch

" (linebreak lbr) The display of a long line is wrapped at word boundaries
" This does not insert an EOL character like formatoptions, which uses
" the textwidth instead of the window width.
set linebreak

" (bs) Allow backspace to continue removing the (auto)indent, eol, or start
" of input mode.
set backspace=indent,eol,start

" (wmnu) When using command-line completion for command names or
" filenames, a menu of possible options is displayed.
set wildmenu

" (wildignore wig) Ignore these files when using tab completion.
set wildignore+=*.py[co]
