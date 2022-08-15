" AdvancedJoiners.vim: More ways to (un-)join lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2005-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! AdvancedJoiners#JoinNum( mode ) abort
    if a:mode ==# 'n'
	return v:count1
    elseif a:mode ==# 'v'
	" The last line isn't joined in visual mode.
	return line("'>") - line("'<")
    else
	throw "unhandled mode '" . a:mode . "'"
    endif
endfunction

function! AdvancedJoiners#RepeatFromMode( mode )
    if a:mode ==# 'n'
	return v:count1
    elseif a:mode ==# 'v'
	return line("'>") - line("'<") + 1
    else
	throw "unhandled mode '" . a:mode . "'"
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
