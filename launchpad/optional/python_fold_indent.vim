" Based on https://dev.launchpad.net/UltimateVimPythonSetup

" (foldignore fdi) By default comments (#) are ignored.
" Only takes effect when the foldmethod is 'indent'.
" (foldmethod fdm) Folds automatically created for each indent level.
" (foldlevelstart fdls) Automatically open folds at the specified level
" when a file is opened. Zero closes all folds. 99 opens all folds.
" (foldminlines fml) Only create a fold of at least this many lines.
set foldignore= foldmethod=indent foldlevelstart=99 foldminlines=5
