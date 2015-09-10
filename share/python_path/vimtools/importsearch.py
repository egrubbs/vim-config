import os
import re
import string
import vim
from .helpers import LP_inputlist
from .highlighter import LP_highlighter
from .importformatter import LP_format_python_import


def LP_python_import_search():
    valid_chars = '_' + string.ascii_letters + string.digits

    line_number, column_number = vim.current.window.cursor
    line_number -= 1 # Convert from 1-indexed to 0-indexed

    line = vim.current.buffer[line_number]
    if line[column_number] not in valid_chars:
        print '"%s" is not part of an identifier' % line[column_number]

    for start in range(column_number, -1, -1):
        if line[start] not in valid_chars:
            start += 1
            break
    for stop in range(column_number, len(line)):
        if line[stop] not in valid_chars:
            break
    else:
        # If it hits the end of the line, the stop index is actually one more.
        stop += 1

    identifier = line[start:stop]
    try:
        result = _find_import_modules(identifier)
    except LookupError:
        result = []
    ordered_result = sorted(item for item in result if item['module'])
    if len(ordered_result) == 0:
        print "%r not found" % identifier
    else:
        options = ['Select import:']
        for i, item in enumerate(ordered_result):
            info = item['match'] or item['kind']
            option = '%s: %-40s %-38s' % (i+1, item['module'], info)
            options.append(option)

        selected = LP_inputlist(options)
        if selected == 0:
            # Selection canceled.
            pass
        else:
            index = selected - 1
            _insert_import_statement(
                ordered_result[index]['module'], identifier)


def _find_init_file(dirname):
    for extension in ('py', 'pyc', 'pyo'):
        init_file = os.path.join(
            dirname, '__init__.%s' % extension)
        if os.path.isfile(init_file):
            return init_file
    return None


class LP_UniqueModuleDict(dict):

    def __hash__(self):
        return hash(self['module'])


def _find_import_modules(tag):
    match_list = vim.eval("taglist('^%s$')" % tag)
    import_list = []
    for match in match_list[:20]:
        # Determine module name.
        filename = match['filename']
        module_parts = []
        if not os.path.exists(filename):
            print "Filename does not exist:", filename
        while True:
            if os.path.isfile(filename):
                module = os.path.basename(os.path.splitext(filename)[0])
            elif os.path.isdir(filename):
                if _find_init_file(filename) is None:
                    break
                module = os.path.basename(filename)
            else:
                # The tags file has references to files that don't
                # exist.
                break
            if module != '__init__':
                module_parts.insert(0, module)
            filename = os.path.dirname(filename)
        if tag in match['cmd']:
            # Remove "/^" and "$/" around the pattern.
            match_definition = match['cmd'][2:-2].strip()
        else:
            if os.path.isfile(filename):
                lines = open(filename).readlines()
            elif os.path.isdir(filename):
                init_file = _find_init_file(filename)
                if init_file is not None:
                    lines = open(filename).readlines()
                else:
                    lines = []
            else:
                lines = []

            # Try to find the definition in the file and look five
            # lines up for the start of the definition.
            match_definition = None
            if lines:
                # Convert to regexp to extended regexp.
                pattern = match['cmd'].replace('(', r'\(')
                pattern = pattern.replace(')', r'\)')
                regex = re.compile(pattern)
                for i, line in enumerate(lines):
                    if regex.match(line):
                        break
                for j in range(i, max(0, i-5), -1):
                    if tag in lines[j]:
                        match_definition = lines[j].strip()

        import_info = LP_UniqueModuleDict(
            module='.'.join(module_parts),
            match=match_definition,
            kind=match['kind'],
            )
        import_list.append(import_info)
    return set(import_list)


def _insert_import_statement(module, identifier):
    half_import_statement = 'from %s ' % module
    import_statement = half_import_statement + 'import ' + identifier

    # If it's a doctest, try inserting above the current statement. If
    # it can't be determined where the statement begins, just insert
    # it above the current line.
    if vim.eval('&filetype') == 'doctest':
        line_number, column_number = vim.current.window.cursor
        start = line_number - 1 # Convert from 1-indexed to 0-indexed.
        place = start
        for i in range(start, -1, -1):
            if '>>>' in vim.current.buffer[i]:
                place = i
                break
        vim.current.buffer[place:place] = ['    >>> %s' % import_statement]
        LP_highlighter.highlight_imported_identifier(identifier, place, place)
        return

    # If the from-module statement already exists in the file, add the
    # identifier to that instead of creating a separate import
    # statement.
    for i, line in enumerate(vim.current.buffer):
        if line.startswith(half_import_statement):
            if '(' in line:
                vim.current.buffer[i] = line + ' ' + identifier + ','
            else:
                vim.current.buffer[i] = line + ', ' + identifier
            vim.current.window.cursor = (i+1, 0)
            buffer_start, buffer_stop = LP_format_python_import()
            LP_highlighter.highlight_imported_identifier(
                identifier, buffer_start, buffer_stop)
            return

    # There is no existing import statement to add the identier to, so
    # determine where it should be placed in the file.
    # The `place` variable is set back to None whenever statements
    # are found that should be above the import statement.
    top_level_module = half_import_statement.split('.')[0]
    place = None
    for i, line in enumerate(vim.current.buffer):
        if line == '':
            if place is None:
                # The first blank line in the file or the first blank line
                # after __metaclass__, __all__, or an import would be good,
                # but there might be a better match, so don't break yet.
                place = i + 1
        elif line.startswith(('__metaclass__', '__all__', 'from ')):
            # The next blank line would be a good place.
            place = None
        if line.startswith(top_level_module):
            # Ideal position.
            place = i
            break
    if place is None:
        # It is normally only possible to get here if the file has no
        # empty lines.
        place = 0
    vim.current.buffer[place:place] = ['', import_statement, '']
    vim.current.window.cursor = (place+2, 0)

    buffer_start, buffer_stop = LP_format_python_import()
    LP_highlighter.highlight_imported_identifier(
        identifier, buffer_start, buffer_stop)
