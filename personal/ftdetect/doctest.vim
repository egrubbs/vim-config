" Lots of different files have the .txt extension, so vim
" needs to look inside the file to determine if it is a doctest.
" The .txt.THIS and .txt.OTHER extensions are created when bzr has
" conflicts merging branches.

autocmd BufRead,BufNewFile *.txt,*.txt.THIS,*.txt.OTHER call s:detect_doctest_file()

func! s:detect_doctest_file()
    if getline(1) =~ '^\*[^ ]*\.txt\*'
        " Do nothing. It's a vim help document.
    else
        if line("$") > 100
            let nmax = 100
        else
            let nmax = line("$")
        endif

        for i in range(2, nmax)
            if getline(i) =~? "^  *>>> "
                setfiletype doctest
                break
            endif
        endfor
    endif
endfunc
