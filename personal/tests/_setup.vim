" Turn syntax highlighting which was disabled in runVimTests.sh.
" Otherwise, we will get errors when loading configs that modify syntax
" highlighting groups.
syntax on

python << EOF
# Set up runtimepath so that it can find vim-config.
import vim
import os
# abspath() is relative to the CWD, which is vim-config/personal/tests.
path = os.path.abspath('../../testing/fake_runtimepath')
vim.command('set runtimepath+=%s' % path)
EOF

runtime vim-config/personal/all.vim
