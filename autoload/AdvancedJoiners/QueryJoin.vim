" AdvancedJoiners/QueryJoin.vim: Join by queried separator.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	005	06-Mar-2018	Define default s:QueryJoin_separator so that
"                               <Leader>[g]J can be used without a previous
"                               <Leader>[g]j.
"                               Refactoring: Extract s:GetSeparator() from
"                               s:Join().
"                               Refactoring: Split off
"                               AdvancedJoiners#QueryJoin#JoinWithSeparator()
"                               and use to implement new gsJ mapping.
"	004	05-Mar-2018	Split off s:Join() from
"                               AdvancedJoiners#QueryJoin#Join(). Add
"                               AdvancedJoiners#QueryJoin#JoinCommand() to
"                               implement :Join.
"                               Need to pass a:repeatMapping to
"                               AdvancedJoiners#QueryJoin#Join(), as it is used
"                               with different a:isKeepIndent values by
"                               <Leader>j and <Leader>gj.
"	003	23-Dec-2016	ENH: Add a:isKeepIndent argument to
"				AdvancedJoiners#QueryJoin#Join(), in order to
"				support new <Leader>gJ variant.
"				BUG: <Leader>J with indented "  )" line eats the
"				parenthesis, because built-in J has special
"				behavior there. Need to check and use "i"
"				instead of "ciw" then.
"				BUG: Separator is inserted one character to
"				early when joining with an empty line. Need to
"				temporarily :set virtualedit=onemore to
"				correctly handle joining of empty lines.
"	002	07-Feb-2013	Avoid clobbering the default register.
"	001	07-Feb-2013	file creation
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
    if a:isKeepIndent && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
	let l:save_virtualedit = &virtualedit
	set virtualedit=onemore " Otherwise, when joining with an empty line, the cursor is one cell left of where we need it.
    endif

    try
	for l:i in range(a:joinNum)
	    " The J command inserts one space in place of the <EOL> unless
	    " there is trailing white space or the next line starts with a ')'.
	    " The whitespace will be handed by "ciw", but we need a special case
	    " for ).
	    let l:joinCommand = (a:isKeepIndent ?
	    \   'gJi' :
	    \   (getline(line('.') + 1) =~# '^\s*)' ?
	    \       'Ji' :
	    \       'J"_ciw'
	    \   )
	    \)

	    let l:bufferTick = b:changedtick
		execute 'normal!' l:joinCommand . a:separator . "\<Esc>"
	    if b:changedtick == l:bufferTick
		" The join failed (because there are no more lines in the buffer).
		" Abort to avoid a cascade of error beeps.
		return 0
	    endif
	endfor

	return 1
    finally
	if exists('l:save_virtualedit')
	    let &virtualedit = l:save_virtualedit
	endif
    endtry
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
    let l:isVisualMode = (a:mode ==# 'v')
    let l:joinNum = (l:isVisualMode ? line("'>") - line("'<") : v:count)
    call s:Join(
    \   a:isKeepIndent,
    \   AdvancedJoiners#RepeatFromMode(a:mode) - (l:isVisualMode ? 1 : 0),
    \   a:separator
    \)
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
