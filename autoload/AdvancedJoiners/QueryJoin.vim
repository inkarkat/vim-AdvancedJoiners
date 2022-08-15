" AdvancedJoiners/QueryJoin.vim: Join by queried separator.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"   - repeat.vim (vimscript #2136) plugin (optional)
"   - visualrepeat.vim (vimscript #3848) plugin (optional)
"
" Copyright: (C) 2005-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:QueryJoin_separator = ''
function! s:GetSeparator( isQuery )
    if a:isQuery
	let s:QueryJoin_separator = input('Enter separator string: ')
    endif
    return s:QueryJoin_separator
endfunction
function! s:Join( isKeepIndent, joinNum, separator )
    let l:joinedCnt = ingo#join#Range(a:isKeepIndent, line('.'), line('.') + a:joinNum, a:separator)
    return (l:joinedCnt == a:joinNum)
endfunction

function! AdvancedJoiners#QueryJoin#JoinCommand( isKeepIndent, startLnum, endLnum, separator )
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    let l:joinNum = l:endLnum - l:startLnum
    let l:save_foldenable = &l:foldenable
    setlocal nofoldenable
    try
	execute l:startLnum
	let s:QueryJoin_separator = a:separator

	if ! s:Join(a:isKeepIndent, l:joinNum, s:GetSeparator(0))
	    call ingo#err#Set(printf('Failed to join %d lines', l:joinNum))
	    return 0
	endif

	return 1
    finally
	let &l:foldenable = l:save_foldenable
    endtry
endfunction

function! AdvancedJoiners#QueryJoin#JoinWithSeparator( isKeepIndent, mode, separator, repeatMapping )
    let l:joinNum = AdvancedJoiners#JoinNum(a:mode)
    if ! s:Join(a:isKeepIndent, l:joinNum, a:separator)
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    endif
    " The last line isn't joined in visual mode.

    silent! call       repeat#set(a:repeatMapping, l:joinNum)
    silent! call visualrepeat#set(a:repeatMapping, l:joinNum)
endfunction
function! AdvancedJoiners#QueryJoin#Join( isKeepIndent, mode, isQuery, repeatMapping )
    call AdvancedJoiners#QueryJoin#JoinWithSeparator(
    \   a:isKeepIndent, a:mode, s:GetSeparator(a:isQuery), a:repeatMapping
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
