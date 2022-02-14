" AdvancedJoiners/Delete.vim: Join lines and delete some text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! AdvancedJoiners#Delete#ToTrailing( mode ) abort
    let l:firstLnum = line('.')
    let l:firstLine = getline(l:firstLnum)
    let l:startOfChange = len(l:firstLine) + 1
    let l:trailingText = matchstr(l:firstLine, '\%(\k\+\|\%(\k\@!\S\)\+\)\ze\s*$')
    if empty(l:trailingText)
	call ingo#err#Set('No trailing text found')
	return 0
    elseif stridx(getline(l:firstLnum + 1), l:trailingText) == -1
	call ingo#err#Set(printf("Following line does not contain '%s'", l:trailingText))
	return 0
    elseif l:firstLnum >= line('$')
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return 1
    endif

    let l:lineNum = AdvancedJoiners#RepeatFromMode(a:mode)
    let l:joinNum = l:lineNum - (a:mode ==# 'v' ? 1 : 0) " The last line isn't joined in visual mode.
    for l:joinCnt in range(1, l:joinNum)
	let l:line = getline(l:firstLnum + l:joinCnt)
	let l:startOfTrailingText = stridx(l:line, l:trailingText)
	if l:startOfTrailingText != -1
	    let l:endOfTrailingText = l:startOfTrailingText + len(l:trailingText)
	    let l:line = strpart(l:line, l:endOfTrailingText)
	endif
	let l:firstLine .= l:line
    endfor

    call ingo#lines#Delete(l:firstLnum + 1, min([l:firstLnum + l:joinNum, line('$')]))
    call setline(l:firstLnum, l:firstLine)
    call cursor(l:firstLnum, l:startOfChange)
    call ingo#change#Set([0, l:firstLnum, l:startOfChange, 0], [0, l:firstLnum, len(l:firstLine) + 1, 0])

    silent! call       repeat#set("\<Plug>(AdvancedJoinersDeleteToTrailing)", l:joinNum)
    silent! call visualrepeat#set("\<Plug>(AdvancedJoinersDeleteToTrailing)", l:joinNum)
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
