" Copyright 2010 Canonical Ltd.  This software is licensed under the
" GNU Affero General Public License version 3 (see the file LICENSE).
"
" Python function to format a python from/import statement by sorting
" the imported items and wrapping the lines.
" Language:     Python (ft=python)
" Last Change:  Wed May 19 09:06:18 CDT 2010
" Maintainer:   Edwin Grubbs <edwin.grubbs@canonical.com>
" Version:      0.1, for Vim 7.2
" URL:

if exists('b:loaded_python_import_macros')
    finish
endif
let b:loaded_python_import_macros = 1

" Add canonical-vim/share/python_path to the PYTHONPATH.
runtime canonical-vim/share/python_path.vim

highlight link NewImportID Todo

python << EOF
    #from vimtools import *
    #vim.command(
    #    'autocmd CursorHold,WinLeave,BufLeave,InsertEnter <buffer> '
    #    'python LP_highlighter.unhighlight()')
EOF
