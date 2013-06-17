" AdvancedJoiners/CommentJoin.vim: Join lines and remove comment prefixes.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	30-May-2013	Tweak the gJ fallback pattern when no comment
"				markers are defined to avoid matching " : in "
"				:Foobar, so that only the " comment prefix is
"				removed.
"	003	10-Apr-2013	Move ingoplugins.vim into ingo-library.
"	002	07-Feb-2013	Avoid clobbering the default register.
"				ENH: Integrate with IndentCommentPrefix.vim
"				plugin and treat its whitelist prefixes as
"				comments, too.
"	001	07-Feb-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:CommentToExpression( comment )
    let [l:flags, l:comment] = matchlist(a:comment, '\([^:]*\):\(.*\)')[1:2]

    " Mask backslash for "very nomagic" pattern.
    let l:comment = escape(l:comment, '\')

    " Observe when a blank is required after the comment string, but do not
    " include it in the match, so that it is preserved during the join.
    " Illustration: With :setlocal comments=b:#,:>
    " # This is				>This is
    " # text.				> specta
    " Will be joined to			>cular.
    " # This is text.			Will be joined to
    "					>This is spectacular.
    return (l:flags =~# 'b' ? l:comment . '\ze\%(\s\|\$\)': l:comment)
endfunction
function! s:GetCommentExpressions()
    if empty(&l:comments)
	" For this buffer, no comment markers are defined. Use any non-word
	" non-whitespace sequence as a generalization.
	let l:commentExpressions = ['\%(\W\&\S\)\+']
    else
	" Convert each comment marker of the 'comments' setting into a regular
	" expression.
	let l:commentExpressions = map(split(&l:comments, '\\\@<!,'), 's:CommentToExpression(v:val)')
    endif

    " Integration with IndentCommentPrefix.vim plugin.
    let l:commentExpressions += map(copy(ingo#plugin#setting#GetBufferLocal('IndentCommentPrefix_Whitelist', [])), 'escape(v:val, ''\\'')')

    return l:commentExpressions
endfunction
function! s:RemoveHyphen()
    if search('\V\w-\%# \s\*\%(\w\|-\)', 'bcnW', line('.'))
	normal! "_X
    endif
endfunction
function! s:SubstituteOnceInLine( pattern, replacement, isMoveLeft )
    if search(a:pattern, 'cnW', line('.'))
	let l:save_cursor = getpos('.')
	if a:isMoveLeft
	    normal! h
	endif
	execute 'silent substitute/' . escape(a:pattern, '/') . '/' . escape(a:replacement, '/') . '/e'
	call setpos('.', l:save_cursor)
	return 1
    endif
    return 0
endfunction
function! AdvancedJoiners#CommentJoin#Join( mode )
    let l:commentPattern = '\%(' . join(s:GetCommentExpressions(), '\|') . '\)'

    " If something is joined with an empty line, no whitespace is inserted.
    " Since the cursor is positioned either on the whitespace (if the original
    " line did not end with whitespace) or after it, the whitespace before
    " l:commentPattern is optional, anyway, and handles that case, too.
    let l:joinedCommentPattern = '\V\%# \?' . l:commentPattern

    let l:noCommentCnt = 0
    let l:isRemoveComments = 1
    let l:lineNum = AdvancedJoiners#RepeatFromMode(a:mode)
    let l:joinNum = l:lineNum - (a:mode ==# 'v' ? 1 : 0) " The last line isn't joined in visual mode.

    if ! search('\V\n\s\*' . l:commentPattern, 'cnW', line('.'))
	" Note: Search for /\n/ does not match in empty line, so explicitly
	" search for that corner case.
	if ! (empty(getline('.')) && search('\V\^\s\*' . l:commentPattern, 'cnW', line('.') + 1))
	    " The next line does not start with a comment string, so switch to "fuse
	    " mode" (i.e. joining and removing any whitespace) instead.
	    let l:joinedCommentPattern = '\V\%(\^\%#\|\%# \s\*\)'
	    let l:isRemoveComments = 0
	endif
    endif

    let l:didSubstitute = 0
    for l:joinCnt in range(1, l:joinNum)
	let l:isEndsWithWhitespace = search('\s$', 'cnW', line('.'))

	let l:bufferTick = b:changedtick
	    if ! l:isRemoveComments && l:isEndsWithWhitespace
		" In "fuse mode", we want trailing whitespace removed as well, so
		" move the cursor to the beginning of whitespace after the join.
		normal! JgEl
	    else
		normal! J
	    endif
	if b:changedtick == l:bufferTick
	    " The join failed (because there are no more lines in the buffer).
	    let l:joinCnt -= 1
	    " Abort to avoid a cascade of error beeps.
	    break
	endif
	if ! l:isRemoveComments
	    call s:RemoveHyphen()
	endif

	if s:SubstituteOnceInLine(l:joinedCommentPattern, '', 0)
	    let l:didSubstitute = 1
	    " Condense any indent remaining after removing the comment string.
	    " Any whitespace before the cursor belongs to the original line and
	    " must be preserved, only indent remaining after removal of the
	    " comment should be removed. There may be no indent if the comment
	    " does not require a blank after the comment string, and in fact
	    " there is none.

	    " The J command positions the cursor on the first character to the line;
	    " this usually is the inserted whitespace, but can also be the first
	    " character if the original line ended with whitespace. In the
	    " latter case, the substitution requires that we move to the left,
	    " so that the inserted indent is to the right of the cursor.
	    call s:SubstituteOnceInLine('\V\%#\s\+', ' ', l:isEndsWithWhitespace)
	else
	    let l:noCommentCnt += 1
	endif
    endfor
    if l:didSubstitute | call histdel('search', -1) | endif " Clean up the search history.

    redraw
    if l:noCommentCnt > 0
	call ingo#msg#WarningMsg(l:joinNum > 1 ? printf('No comment in %d line%s', l:noCommentCnt, (l:noCommentCnt == 1 ? '' : 's')) : 'No comment detected')
    else
	echomsg printf('%s%s %d %sline%s',
	\   (l:isRemoveComments ? 'Joined' : 'Fused'),
	\   (a:mode ==# 'v' ? ' together' : ''),
	\   l:joinCnt,
	\   (l:isRemoveComments ? 'comment ' : ''),
	\   (l:joinCnt == 1 ? '' : 's')
	\)
    endif

    silent! call       repeat#set("\<Plug>(CommentJoin)", l:joinNum)
    silent! call visualrepeat#set("\<Plug>(CommentJoin)", l:joinNum)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
