
if exists("b:loaded_canonical_python_path")
    finish
endif
let b:loaded_canonical_python_path = 1

python << EOF
import vim
import sys
import os
canonical_vim_dir = vim.eval('globpath(&runtimepath, "vim-config")')
python_path = os.path.join(canonical_vim_dir, 'share/python_path')
sys.path.insert(0, python_path)
EOF
