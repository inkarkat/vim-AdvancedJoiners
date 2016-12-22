" AdvancedJoiners/QueryJoin.vim: Join by queried separator.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	07-Feb-2013	Avoid clobbering the default register.
"	001	07-Feb-2013	file creation

function! AdvancedJoiners#QueryJoin#Join( mode, isQuery )
    let l:joinNum = (a:mode ==# 'v' ? line("'>") - line("'<") : v:count)

    if a:isQuery
	let s:QueryJoin_separator = input('Enter separator string: ')
    endif
    for i in range(AdvancedJoiners#RepeatFromMode(a:mode) - (a:mode == 'v' ? 1 : 0)) " The last line isn't joined in visual mode.
	let l:bufferTick = b:changedtick
	    execute 'normal! J"_ciw' . s:QueryJoin_separator . "\<Esc>"
	if b:changedtick == l:bufferTick
	    " The join failed (because there are no more lines in the buffer).
	    " Abort to avoid a cascade of error beeps.
	    break
	endif
    endfor

    silent! call       repeat#set("\<Plug>(RepeatQueryJoin)", l:joinNum)
    silent! call visualrepeat#set("\<Plug>(RepeatQueryJoin)", l:joinNum)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
