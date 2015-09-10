" The SpellBad highlight group specifies a ctermbg color, but it doesn't
" specify a foreground color, so it is possible for it to make text
" invisible when the syntax highlighting for the filetype is the same
" color. Therefore, we specify the background and foreground color here,
" to make sure that they are different no matter what colorscheme you
" are using. We are not changing the guifg/guibg that gvim uses, since
" it uses a curly red underline instead.
"
" pyflakes.vim highlights with the SpellBad group, so you have to worry
" about this even if you don't use the spellchecker.
"
" vim default for SpellBad: term=reverse ctermbg=Red gui=undercurl guisp=Red
highlight SpellBad ctermbg=Red ctermfg=Yellow
