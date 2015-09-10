import vim


def LP_inputlist(options):
    """Wrap the inputlist() vim function.

    This allows tests to provide a mock function, since vim doesn't allow
    overriding built-in functions, and runVimTests is not able to automate
    input to the inputlist() prompt.
    """
    # vim.eval() can't deal with a double-quote inside of single
    # quotes, but it can if double-quotes are escaped inside of
    # double-quotes.
    options = ['"%s"' % option.replace('"', r'\"')
               for option in options]
    return int(vim.eval('inputlist([%s])' % ', '.join(options)))
