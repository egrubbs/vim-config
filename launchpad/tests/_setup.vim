" Turn syntax highlighting which was disabled in runVimTests.sh.
" Otherwise, we will get errors when loading configs that modify syntax
" highlighting groups.
syntax on

python << EOF
# Set up runtimepath so that it can find canonical-vim.
import vim
import os
# abspath() is relative to the CWD, which is canonical-vim/launchpad/tests.
path = os.path.abspath('../../testing/fake_runtimepath')
vim.command('set runtimepath+=%s' % path)
EOF

runtime canonical-vim/launchpad/all.vim
