import vim


class LP_HighlighterClass:

    def __init__(self):
        self.matches = []

    def unhighlight(self):
        while len(self.matches) > 0:
            vim.eval("matchdelete('%s')" % self.matches.pop())

    def highlight_imported_identifier(
        self, identifier, buffer_start, buffer_stop):
        """Highlight new identifier in import statement."""
        self.unhighlight()
        # Convert buffer_start/stop zero-indexed values to 1-indexed line
        # numbers.
        lineno_above = buffer_start
        lineno_below = buffer_stop + 2
        not_followed_by_import = r'\(.* import \)\@!'

        pattern = ((r'\%>' + str(lineno_above) + r'l')
                + (r'\%<' + str(lineno_below) + r'l')
                + '\(^\|\A\)' + identifier + '\(\A\|$\)'
                + not_followed_by_import)
        # The string literals passed into matchadd() should have single quotes
        # around the pattern so that it doesn't remove backslashes.
        match_id = vim.eval("matchadd('NewImportID', '%s')" % pattern)
        self.matches.append(match_id)

LP_highlighter = LP_HighlighterClass()
