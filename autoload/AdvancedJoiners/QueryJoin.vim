" AdvancedJoiners/QueryJoin.vim: Join by queried separator.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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

function! AdvancedJoiners#QueryJoin#Join( isKeepIndent, mode, isQuery )
    if a:isKeepIndent && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
	let l:save_virtualedit = &virtualedit
	set virtualedit=onemore " Otherwise, when joining with an empty line, the cursor is one cell left of where we need it.
    endif

    try
	let l:joinNum = (a:mode ==# 'v' ? line("'>") - line("'<") : v:count)

	if a:isQuery
	    let s:QueryJoin_separator = input('Enter separator string: ')
	endif
	for i in range(AdvancedJoiners#RepeatFromMode(a:mode) - (a:mode == 'v' ? 1 : 0)) " The last line isn't joined in visual mode.
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
		execute 'normal!' l:joinCommand . s:QueryJoin_separator . "\<Esc>"
	    if b:changedtick == l:bufferTick
		" The join failed (because there are no more lines in the buffer).
		" Abort to avoid a cascade of error beeps.
		break
	    endif
	endfor

	silent! call       repeat#set("\<Plug>(RepeatQueryJoin)", l:joinNum)
	silent! call visualrepeat#set("\<Plug>(RepeatQueryJoin)", l:joinNum)
    finally
	if exists('l:save_virtualedit')
	    let &virtualedit = l:save_virtualedit
	endif
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
