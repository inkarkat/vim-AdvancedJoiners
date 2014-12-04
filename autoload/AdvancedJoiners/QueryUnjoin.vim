" AdvancedJoiners/QueryUnjoin.vim: Unjoin by queried pattern.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	30-May-2014	Also handle unjoin with zero-width pattern, e.g.
"				"<Bar>\zs".
"	002	07-Feb-2013	Avoid clobbering the default register.
"	001	07-Feb-2013	file creation

" Note: The simplest version is s/<pat>/\r/g, but that one doesn't handle the
" indenting. Indenting after-the-fact with = isn't guaranteed to be the same
" (e.g. for 'autoindent'), so we do the replacement step by step manually.
function! s:UnjoinLine( separator )
    " Start from the beginning of the line.
    normal! 0

    " To select the entire search pattern, we first go to the end of the match,
    " then search backward to the beginning of the match (accepting at-cursor
    " match for a one-character match), while setting mark ' at the previous
    " (i.e. end-of-match) position. Then we delete from the current position
    " (beginning of match) to mark ', which removes everything but the final
    " character, which is finally replaced with the 's' command.
    while search(a:separator, 'ceW', line('.'))
	" In case of a single-character match, the cursor position doesn't
	" change, and search(..., 's') doesn't set the ' mark. So we have to
	" make sure it is set.
	normal! m'
	call search(a:separator, 'cbsW', line('.'))
	if getpos('.') == getpos("''")
	    " Either this was a one-character match, or a zero-character match
	    " (possible when unjoining with a pattern ending in \zs), or
	    " something went wrong. To differentiate between the two, try to
	    " match the separator in the current line.
	    if empty(matchstr(getline('.'), a:separator))
		execute "normal! i\<CR>\<Esc>"
	    else
		execute "normal! s\<CR>\<Esc>"
	    endif
	else
	    " Replace the separator with a newline.
	    execute "normal! \"_dg`'s\<CR>\<Esc>"
	endif
    endwhile
endfunction
function! AdvancedJoiners#QueryUnjoin#Unjoin( mode, isQuery )
    let l:startLnum = line('.')
    let l:unjoinNum = (a:mode ==# 'v' ? line("'>") - line("'<") + 1 : v:count)

    if a:isQuery
	let s:QueryUnjoin_separator = input('Enter separator pattern: ')
    endif
    for l:i in range(AdvancedJoiners#RepeatFromMode(a:mode))
	let l:lnum = line('.')
	if l:i > 0
	    normal! j
	    if line('.') == l:lnum
		" There are no more lines in the buffer.
		" Abort to avoid a cascade of error beeps.
		break
	    endif
	endif

	call s:UnjoinLine(s:QueryUnjoin_separator)
    endfor

    " The change markers are just around the unjoin. Set them to include all
    " unjoined lines.
    call setpos("'[", [0, l:startLnum, 1, 0])
    call setpos("']", [0, line('.'), 0x7FFFFFFF, 0])

    silent! call       repeat#set("\<Plug>(RepeatQueryUnjoin)", l:unjoinNum)
    silent! call visualrepeat#set("\<Plug>(RepeatQueryUnjoin)", l:unjoinNum)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
