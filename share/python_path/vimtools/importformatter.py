import logging
import re
import vim


class LPFormatter:
    logger = logging.getLogger()

    def __call__(self, vertical=False):
        MAX_LINE_LENGTH = 78
        line_number, column_number = vim.current.window.cursor
        line_number -= 1 # Convert from 1-indexed to 0-indexed

        line = vim.current.buffer[line_number]
        self.logger.debug('start line: %r' % line)
        match = re.match(
            r'(\s*)from\s+[A-Za-z_][A-Za-z0-9_.]*\s+import\s+',
            line)
        if match is None:
            print 'from/import statement not found: %r' % line
            return

        from_indent = match.group(1)
        module_indent = from_indent + (' ' * 4)

        # Fill the 'statement' variable with all the text for the
        # from/import statement.
        statement = line
        statement_size = 1
        if '(' not in statement:
            # Single line import statement.
            from_expr = r'(.*import *)'
            full_expr = from_expr + r'(.*)'
        else:
            # Multi line import statement.
            for i in range(line_number+1, len(vim.current.buffer)):
                if ')' in statement:
                    break
                statement_size += 1
                statement += vim.current.buffer[i]

            from_expr = r'(.*import[^( ]*) *\('
            full_expr = from_expr + r'(.*)\)'

        # Parse the from/import statement.
        match = re.match(full_expr, statement)
        if match is None:
            print "Error processing this import"
            return

        from_part, module_part = match.groups()
        from_part = from_part.rstrip() + ' '
        self.logger.debug('from_part: %r' % from_part)
        self.logger.debug('module_part: %r' % module_part)

        # Sort and remove duplicates from the imported items.
        modules = set(module.strip() for module in module_part.split(','))
        # Multiline imports might end with a comma, newline, and close paren,
        # so remove any empty module.
        modules.remove('')
        modules = sorted(modules, key=str.lower)

        if vertical == True:
            pass
        else:
            new_statement_size, module_groups = (
                self._horizontal_import_calculation(
                    module_indent, from_part, modules))

        # If the newly formatted from/import statement will have more lines
        # than before (size_diff>0), insert lines into the buffer. If it will
        # have less lines, clear the text from the extra lines of the old
        # from/import statement.
        size_diff = new_statement_size - statement_size
        if size_diff > 0:
            after = line_number + statement_size
            vim.current.buffer[after:after] = [''] * size_diff
        elif size_diff < 0:
            for i in range(new_statement_size, statement_size):
                vim.current.buffer[line_number+i] = ''

        # Add the new from/import statement without parens if it's a single
        # line or with parens for multiple lines.
        if new_statement_size == 1:
            vim.current.buffer[line_number] = (
                from_part + ', '.join(module_groups[0]))
            return (line_number, line_number)
        else:
            vim.current.buffer[line_number] = from_part + '('
            for i in range(0, len(module_groups)):
                current_line = line_number + i + 1
                new_line = module_indent + ', '.join(module_groups[i])
                if i+1 == len(module_groups):
                    new_line += ')'
                else:
                    new_line += ','
                vim.current.buffer[current_line] = new_line
            return (line_number, line_number+len(module_groups))

    def _horizontal_import_calculation(
        self, module_indent, from_part, modules):
        # Split the imported module names into lines to fall under the
        # MAX_LINE_LENGTH.
        def sum(x, y):
            return x + y
        module_groups = [[modules[0]]]
        last_group = module_groups[-1]
        for module in modules[1:]:
            group_length = reduce(sum, [len(i) for i in last_group])
            comma_length = len(', ') * len(last_group) + len(',')
            line_length = (len(module_indent) + group_length
                        + comma_length + len(module))
            if line_length > 78:
                last_group = [module]
                module_groups.append(last_group)
            else:
                last_group.append(module)

        # Determine whether the from/import statement fits in one line.
        if (len(module_groups) == 1
            and (len(from_part) + len(', '.join(module_groups[0])) <= 78)):
            new_statement_size = 1
        else:
            new_statement_size = len(module_groups) + 1
        return new_statement_size, module_groups


LP_format_python_import = LPFormatter()
