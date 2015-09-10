__metaclass__ = type

import logging
import sys
from textwrap import dedent
from unittest import (
    main,
    TestCase,
    )


class MockVimWindow:
    __slots__ = ['_cursor']

    def __init__(self):
        self._cursor = (1, 0)

    def _get_cursor(self):
        return self._cursor

    def _set_cursor(self, value):
        line_number, column_number = value
        assert isinstance(value, tuple)
        assert isinstance(line_number, int)
        assert isinstance(column_number, int)
        assert line_number >= 1
        self._cursor = value

    cursor = property(_get_cursor, _set_cursor)


class MockVimCurrent:
    __slots__ = ['_buffer']

    window = MockVimWindow()

    def __init__(self):
        self._buffer = []

    def _get_buffer(self):
        return self._buffer

    def _set_buffer(self, value):
        assert isinstance(value, list)
        self._buffer = value

    buffer = property(_get_buffer, _set_buffer)


class MockVimModule:
    """Mock vim module that normally exists in vim's python plugin."""
    __slots__ = []

    current = MockVimCurrent()

sys.modules['vim'] = MockVimModule()
from vimtools.importformatter import LP_format_python_import
import vim


class TestFormatter(TestCase):

    def test_format_to_single_line(self):
        vim.current.buffer = dedent('''
            from alpha import (
                gamma,
                beta,
                )
            ''').split('\n')
        expected = dedent('''
            from alpha import beta, gamma



            ''').split('\n')
        vim.current.window.cursor = (2, 0)
        logging.basicConfig(stream=sys.stderr)
        LP_format_python_import.logger.setLevel(logging.DEBUG)
        LP_format_python_import()
        self.assertEqual(expected, vim.current.buffer)
        print "---- Buffer ----"
        for line in vim.current.buffer:
            print repr(line)

main()
