" Copyright 2010 Canonical Ltd.  This software is licensed under the GNU
" Affero General Public License version 3 (see the file LICENSE).
"
" pocketlint.vim - A script to highlight syntax errors. 
" * Python syntax and style 
" * Python doctest style 
" * XML/HTML style and entities 
" * CSS style 
" * JavaScript syntax and style 
" * Plain text 
" * Supports reporting: 
" * Python doctests 
" * CSS 
" * XML/HTML
"
" Depends on pocket-lint project:
"   https://launchpad.net/pocket-lint
"
" This plugin is based on the pyflakes plugin by Kevin Watters
" <kevin.watters@gmail.com>.
"
" Maintainer:   Edwin Grubbs <edwin.grubbs@canonical.com>
" Version:      0.1, for Vim 7.2

if exists("b:did_pocketlint_plugin")
    finish " only load once
else
    let b:did_pocketlint_plugin = 1
endif

if !exists('g:pocketlint_builtins')
    let g:pocketlint_builtins = []
endif

if !exists('g:pocketlint_filter')
    let g:pocketlint_filter = ''
endif

if !exists("b:did_python_init")
    python << EOF
import vim
import os.path
import sys
import tokenize
import time
import re

from pocketlint.formatcheck import Language, UniversalChecker
from operator import attrgetter

class blackhole(object):
    write = flush = lambda *a, **k: None

def check(buffer, reporter):
    filename = buffer.name
    contents = '\n'.join(buffer[:]) + '\n'

    # Do not convert the str to a unicode object, since python compile() fails
    # if the python source specifies the encoding when it is in a unicode
    # object.
    # http://www.python.org/dev/peps/pep-0263/
    #
    #vimenc = vim.eval('&encoding')
    #if vimenc:
    #    contents = contents.decode(vimenc)

    builtins = []
    try:
        builtins = eval(vim.eval('string(g:pocketlint_builtins)'))
    except Exception:
        pass

    try:
        old_stderr, sys.stderr = sys.stderr, blackhole()
        old_stdout, sys.stdout = sys.stdout, blackhole()
        try:
            language = Language.get_language(filename)
            pocketlint_checker = UniversalChecker(
                filename,
                text=contents,
                language=language,
                reporter=reporter,
                )
            pocketlint_checker.check()
        finally:
            sys.stderr = old_stderr
            sys.stdout = old_stdout
    except IOError:
        # The pep8 checker needs an actual file, so it fails when
        # someone hasn't saved a file for the first time yet.
        print 'Minimal PocketLint checking until the file is written'
    except IndexError, e:
        line_no = 1
        report_warning(line_no, str(e), file_name=filename)
    except ValueError, e:
        # Handles doctest file that unindents without a blank line in between.
        #     >>> foo
        # bar
        tokens = e.args[0].split()
        # Default to showing an error on the first line.
        line_no = 1
        if len(tokens) >= 2 and tokens[0] == 'line':
            try:
                line_no = int(tokens[1])
            except ValueError:
                pass
        report_warning(line_no, str(e), file_name=filename)
    except IndentationError, e:
        # XXX: https://bugs.edge.launchpad.net/pocket-lint/+bug/610888
        # Pocketlint should report this error normally instead of raising
        # an exception.
        message, info = e.args
        ignore, line_no, offset, ignore = info
        report_warning(line_no, message, column=offset, file_name=filename)
    except tokenize.TokenError, e:
        # Handle pyflakes/pep8 tokenize.TokenError due to unparsable python.
        if len(e.args) == 2 and len(e.args[1]) == 2:
            line_no, offset = e.args[1][0], None
        else:
            line_no, offset = (1, None)
        # XXX: check() and report_warning() should be refactored into a class
        # so that report_warning() can check the line_no against the length
        # of the buffer without passing more arguments.
        if line_no >= len(buffer):
            line_no = len(buffer)
        message = 'Syntax error: %s' % str(e.args[0])
        if 'EOF' in e.args[0]:
            message += ' (Look for unclosed paren, bracket, etc.)'
        report_warning(line_no, message, column=offset, file_name=filename)

def vim_quote(s):
    return s.replace("'", "''").replace('\n', ' ')
EOF
    let b:did_python_init = 1
endif

" XXX: Too annoying for big files when it is slow.
"au BufEnter <buffer> call s:RunPocketlint()
"au InsertLeave <buffer> call s:RunPocketlint()

" Rerun pocketlint.
au BufWinEnter <buffer> call s:RunPocketlint()
au BufWritePost <buffer> call s:RunPocketlint()
au CursorHold <buffer> call s:RunPocketlint()

" Make sure the warning message displayed for the line under the cursor
" is up-to-date.
au CursorHold <buffer> call s:GetPocketlintMessage()
au CursorMoved <buffer> call s:GetPocketlintMessage()

if !exists("*s:PocketlintUpdate")
    function s:PocketlintUpdate()
        silent call s:RunPocketlint()
        call s:GetPocketlintMessage()
    endfunction
endif

" Call this function in your .vimrc to update Pocketlint
if !exists(":PocketlintUpdate")
  command PocketlintUpdate :call s:PocketlintUpdate()
endif

" XXX: This is too slow when the file is really large.
" Hook common text manipulation commands to update Pocketlint
"   TODO: is there a more general "text op" autocommand we could register
"   for here?
"noremap <buffer><silent> dd dd:PocketlintUpdate<CR>
"noremap <buffer><silent> dw dw:PocketlintUpdate<CR>
"noremap <buffer><silent> u u:PocketlintUpdate<CR>
"noremap <buffer><silent> <C-R> <C-R>:PocketlintUpdate<CR>

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
    function s:WideMsg(msg)
        let x=&ruler | let y=&showcmd
        set noruler noshowcmd
        redraw
        echo a:msg
        let &ruler=x | let &showcmd=y
    endfun
endif

if !exists("*s:RunPocketlint")
    function s:RunPocketlint()
        highlight link Pocketlint SpellBad

        if exists("b:cleared")
            if b:cleared == 0
                silent call s:ClearPocketlint()
                let b:cleared = 1
            endif
        else
            let b:cleared = 1
        endif

        let b:matched = []
        let b:matchedlines = {}
        python << EOF

def ez_vim_command(command_string):
    "Include the command_string in the exception info."
    try:
        vim.command(command_string)
    except vim.error, e:
        raise AssertionError('(%r) %r for %s' % (vim.error, e, command_string))

def report_warning(line_no, message, icon=None, base_dir=None, file_name=None,
                   column=None):
    # Don't highlight errors that match the g:pocketlint_filter regexp.
    if vim.eval('exists("g:pocketlint_filter")'):
        pocketlint_filter = re.compile(vim.eval('g:pocketlint_filter'))
        if pocketlint_filter.search(message):
            return
    # Errors should be a number and 1-indexed. Prepend the bogus line_no
    # to the error message and highlight the first line.
    try:
        line_no = int(line_no)
    except ValueError:
        pass
    if not isinstance(line_no, int) or line_no < 1:
        message = '(line: %r) %s' % (line_no, message)
        line_no = 1
    ez_vim_command('let s:matchDict = {}')
    ez_vim_command("let s:matchDict['lineNum'] = " + str(line_no))
    # It is really annoying when the error message wraps, and you
    # feel like you are stuck trying to get out of the pager, so
    # the message should be truncated to one less than the terminal columns.
    term_column_count = int(vim.eval('&columns'))
    ez_vim_command(
        "let s:matchDict['message'] = '%s'"
        % vim_quote(message[:term_column_count-1]))
    ez_vim_command("let b:matchedlines[" + str(line_no) + "] = s:matchDict")

    # XXX: Pocketlint should provide the column number from warnings
    # that it gets from pyflakes.
    if column is None:
        # Without column information, just highlight the whole line.
        ez_vim_command(r"let s:mID = matchadd('Pocketlint', '\%"
                    + str(line_no) + r"l')")
    else:
        # With a column number, highlight the first keyword there.
        ez_vim_command(r"let s:mID = matchadd('Pocketlint', '^\%"
                    + str(line_no) + r"l\_.\{-}\zs\k\+\k\@!\%>"
                    + str(column) + r"c')")

    ez_vim_command("call add(b:matched, s:matchDict)")

check(vim.current.buffer, report_warning)

EOF
        let b:cleared = 0
    endfunction
end

" keep track of whether or not we are showing a message
let b:showing_message = 0

if !exists("*s:GetPocketlintMessage")
    function s:GetPocketlintMessage()
        let s:cursorPos = getpos(".")

        " Bail if RunPocketlint hasn't been called yet.
        if !exists('b:matchedlines')
            return
        endif

        " if there's a message for the line the cursor is currently on, echo
        " it to the console
        if has_key(b:matchedlines, s:cursorPos[1])
            let s:pocketlintMatch = get(b:matchedlines, s:cursorPos[1])
            call s:WideMsg(s:pocketlintMatch['message'])
            let b:showing_message = 1
            return
        endif

        " otherwise, if we're showing a message, clear it
        if b:showing_message == 1
            echo
            let b:showing_message = 0
        endif
    endfunction
endif

if !exists('*s:ClearPocketlint')
    function s:ClearPocketlint()
        let s:matches = getmatches()
        for s:matchId in s:matches
            if s:matchId['group'] == 'Pocketlint'
                call matchdelete(s:matchId['id'])
            endif
        endfor
        let b:matched = []
        let b:matchedlines = {}
        let b:cleared = 1
    endfunction
endif

if !exists('*g:LintOff')
  function g:LintOff()
    function! s:RunPocketlint()
    endfun

    silent call s:ClearPocketlint()
    echo 'pocket-lint disabled'
  endfun
endif
