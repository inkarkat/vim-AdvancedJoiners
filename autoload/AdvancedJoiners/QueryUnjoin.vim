" AdvancedJoiners/QueryUnjoin.vim: Unjoin by queried pattern.
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
"
" REVISION	DATE		REMARKS
"	010	26-May-2019	Regression: Need to pass l:startLnum to new
"                               s:SetChange().
"	009	03-Apr-2019	Refactoring: Use ingo#change#Set(). Factor out
"                               s:SetChange().
"	008	13-May-2018	Implement :Unjoin via
"                               AdvancedJoiners#QueryUnjoin#UnjoinCommand().
"	007	06-Mar-2018	Define default s:QueryUnjoin_separator so that
"                               <Leader>uJ can be used without a previous
"                               <Leader>uj.
"	006	05-Mar-2018	Align Plug-mapping names and consistently prefix
"				with AdvancedJoiners.
"	005	25-Aug-2017	Revert previous change, it breaks indenting.
"				Instead, we need to temporarily :set
"				virtualedit=onemore to avoid an endless loop in
"				that situation.
"				ENH: Delete indent from indent-only lines.
"				Add check for endless recursion which can be
"				caused by the auto-insertion of a comment
"				leader.
"	004	05-Dec-2014	BUG: Endless loop when <Leader>uj with separator
"				<Space> on indented file with "dosbatch"
"				filetype. Temporarily :set paste to disable
"				'formatoptions' and indenting.
"	003	30-May-2014	Also handle unjoin with zero-width pattern, e.g.
"				"<Bar>\zs".
"	002	07-Feb-2013	Avoid clobbering the default register.
"	001	07-Feb-2013	file creation

" Note: The simplest version is s/<pat>/\r/g, but that one doesn't handle the
" indenting. Indenting after-the-fact with = isn't guaranteed to be the same
" (e.g. for 'autoindent'), so we do the replacement step by step manually.
function! s:UnjoinLine( separator )
    if ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
	let l:save_virtualedit = &virtualedit
	set virtualedit=onemore " Otherwise, when joining with an empty line, the cursor is one cell left of where we need it.
    endif
    try
	let l:remainder = getline('.')

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

	    if getline('.') ==# l:remainder
		break   " Avoid endless recursion when the remainer to be unjoined does not get smaller.
	    elseif getline(line('.') - 1) =~# '^\s\+$'
		" Delete indent from indent-only line.
		let l:save_cursor = ingo#compat#getcurpos()
		    -1normal! 0"_D
		call setpos('.', l:save_cursor)
	    endif
	    let l:remainder = getline('.')
	endwhile
    finally
	if exists('l:save_virtualedit')
	    let &virtualedit = l:save_virtualedit
	endif
    endtry
endfunction
let s:QueryUnjoin_separator = '\s\+'
function! AdvancedJoiners#QueryUnjoin#Unjoin( mode, isQuery )
    let l:startLnum = line('.')
    let l:unjoinNum = AdvancedJoiners#RepeatFromMode(a:mode)

    if a:isQuery
	let s:QueryUnjoin_separator = input('Enter separator pattern: ')
    endif
    for l:i in range(l:unjoinNum)
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

    call s:SetChange(l:startLnum)
    silent! call       repeat#set("\<Plug>(AdvancedJoinersUnjoinRepeat)", l:unjoinNum)
    silent! call visualrepeat#set("\<Plug>(AdvancedJoinersUnjoinRepeat)", l:unjoinNum)
endfunction

function! AdvancedJoiners#QueryUnjoin#UnjoinCommand( isNoIndentingAndFormatting, startLnum, endLnum, separator )
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]

    if ! empty(a:separator)
	let s:QueryUnjoin_separator = a:separator
    endif

    if a:isNoIndentingAndFormatting
	let l:save_paste = &paste
	set paste
    endif
    try
	for l:i in range(l:endLnum - l:startLnum + 1)
	    if l:i > 0
		normal! j
	    endif
	    call s:UnjoinLine(s:QueryUnjoin_separator)
	endfor
    finally
	if exists('l:save_paste')
	    let &paste = l:save_paste
	endif
    endtry

    if line('.') == l:endLnum
	call ingo#err#Set('Nothing unjoined; pattern did not match: ' . s:QueryUnjoin_separator)
	return 0
    endif

    call s:SetChange(l:startLnum)

    return 1
endfunction

function! s:SetChange( startLnum ) abort
    " The change markers are just around the last unjoin. Set them to include
    " all unjoined lines.
    call ingo#change#Set([a:startLnum, 1], [line('.'), 0x7FFFFFFF])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
