#!/bin/bash

# -V:       Turn on verbosity to find out when the "runtime" command
#           fails to find a .vim file.
# -e:       Start vim in Ex mode.
# -X:       Don't connect to X server for copy/paste.
# -i NONE:  Disable .viminfo file.
# -c        Pass in Ex commands.

check_dir=$(dirname $0)
echo 'checkdir:' $check_dir

function check_personal_ftplugin {
    extension=${1:?Missing extension argument}
    ftplugin_filename=${2:?Missing name of ftplugin file}

    echo "Was the personal/ftplugin/$ftplugin_filename sourced for a .$extension file?"
    result=$(\
        vim -V2 -e -X -i NONE \
        -c "e ${check_dir}/dummy_file_for_testing.${extension}" \
        -c "echo 'Detected filetype: ' . &filetype" \
        -c quit \
        2>&1)
    
    echo $result \
        | grep -q "sourcing \".*personal/ftplugin/${ftplugin_filename}"
    # Check error code for grep.
    if [ "$?" = 0 ]; then
        echo "   YES"
    else
        echo "   NO"
        # Indent multiline result.
        echo "$result" | grep 'Detected filetype' | sed -re 's/^/   /'
    fi
    echo
}

echo
check_personal_ftplugin py python/basic.vim
check_personal_ftplugin py python/load_pocketlint.vim
check_personal_ftplugin html html.vim
# .pt files are recognized as html files, so the html.vim is loaded.
check_personal_ftplugin pt html.vim
check_personal_ftplugin zcml xml.vim
check_personal_ftplugin txt doctest.vim
check_personal_ftplugin css css.vim
check_personal_ftplugin js javascript.vim
