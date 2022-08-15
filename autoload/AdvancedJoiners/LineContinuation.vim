" AdvancedJoiners/LineContinuation.vim: Join lines that are separated by a line continuation character.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"   - repeat.vim (vimscript #2136) plugin (optional)
"   - visualrepeat.vim (vimscript #3848) plugin (optional)
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:JoinWithPattern( continuationPattern, replacement, what, repeatMapping, mode )
    let l:joinNum = AdvancedJoiners#JoinNum(a:mode, 0)

    let l:continuationCnt = 0
    for l:joinCnt in range(1, (l:joinNum == 0 ? line('$') : l:joinNum))
	if l:joinNum == 0 && getline('.') !~# a:continuationPattern . '\s*$'
	    let l:joinCnt -= 1
	    break
	endif

	let l:hasCurrentTrailingWhitespace = (getline('.') =~# '\s' . a:continuationPattern . '\s*$')
	let l:hasNextIndent = (getline(line('.') + 1) =~# '^\s')

	let l:bufferTick = b:changedtick
	normal! J
	if b:changedtick == l:bufferTick
	    " The join failed (because there are no more lines in the buffer).
	    let l:joinCnt -= 1
	    " Abort to avoid a cascade of error beeps.
	    break
	endif

	let l:originalLine = getline('.')
	let l:newLine = substitute(l:originalLine, a:continuationPattern . '\%' . col('.') . 'c\s*', a:replacement . (l:hasNextIndent && ! l:hasCurrentTrailingWhitespace ? ' ' : ''), '')
	if l:originalLine !=# l:newLine
	    call setline('.', l:newLine)
	    let l:continuationCnt += 1
	endif
    endfor

    redraw
    if l:continuationCnt > 0
	echomsg printf('Joined%s %d %s%s',
	\   (a:mode ==# 'v' ? ' together' : ''),
	\   l:continuationCnt,
	\   a:what,
	\   (l:continuationCnt == 1 ? '' : 's')
	\) . (l:continuationCnt != l:joinCnt ?
	\   printf(' in %d line%s', l:joinCnt, (l:joinCnt == 1 ? '' : 's')) :
	\   ''
	\)
    else
	call ingo#msg#WarningMsg(l:joinNum > 1 ? printf('No %s in %d lines', a:what, l:joinNum) : 'No ' . a:what . ' detected')
    endif

    silent! call       repeat#set(a:repeatMapping, l:joinNum)
    silent! call visualrepeat#set(a:repeatMapping, l:joinNum)
endfunction

function! AdvancedJoiners#LineContinuation#Join( mode ) abort
    call s:JoinWithPattern('\\', '', 'line continuation', "\<Plug>(AdvancedJoinersLineContinuation)", a:mode)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
