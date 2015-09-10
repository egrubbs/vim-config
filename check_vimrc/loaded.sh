#!/bin/bash

# -V:       Turn on verbosity to find out when the "runtime" command
#           fails to find a .vim file.
# -e:       Start vim in Ex mode.
# -X:       Don't connect to X server for copy/paste.
# -i NONE:  Disable .viminfo file.
# -c        Pass in Ex commands.

# Use the 'strings' command to filter out terminal control characters.
echo
echo "      *** THE FOLLOWING FILES WERE LOADED ***"
exec vim -V2 -e -X -i NONE -c quit 2>&1 \
    | grep -v "not found in 'runtimepath': \"ftdetect/\*\.vim\"" \
    | grep 'sourcing "' \
    | sed -re 's/^line [0-9]*: //' \
    | sort \
    | strings

echo
echo "      *** THE FOLLOWING FILES COULD NOT BE LOADED ***"
# Search backwards 20 lines to find the file that is trying to source
# a file that can't be found, grep the important parts, and then limit
# it to the 2 lines above, which are the important ones.
# Use verbosity level 15 to get the line number.
exec vim -V15 -e -X -i NONE -c quit 2>&1 \
    | grep -v "not found in 'runtimepath': \"ftdetect/\*\.vim\"" \
    | grep -E --before=20 '^(Cannot open|not found)' \
    | grep -E '^(continuing |line |Cannot open|^not found)' \
    | grep -E --before=2 '^(Cannot open|not found)' \
    | strings

echo
