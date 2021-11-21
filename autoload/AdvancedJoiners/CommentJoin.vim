" AdvancedJoiners/CommentJoin.vim: Join lines and remove comment prefixes.
"
" DEPENDENCIES:
"   - QueryUnjoin.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"   - ingo/regexp/comments.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2005-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	008	25-Mar-2018	BUG: gqJ fuses = eats all whitespace, whereas it
"                               should keep one whitespace. Split s:diffPattern
"                               into s:diffPatternKeepSeparatingWhitespace,
"                               which is now used for gqJ, and
"                               s:diffPatternAndWhitespace, which is used by
"                               gcqJ, as there we need to remove all whitespace
"                               (and can't use \ze as the comment pattern still
"                               follows).
"                               BUG: Making the commentPattern optional by
"                               appending \? doesn't work well. Instead, add
"                               another branch with just
"                               s:diffPatternKeepSeparatingWhitespace (also
"                               different; see above!) and no commentPattern.
"                               ENH: DWIM: Also remove diff markers from the
"                               beginning of the first joined line. Make
"                               AdvancedJoiners#CommentJoin#WithPattern() take
"                               an optional Funcref and arguments, and invoke
"                               that after the joining, but before histdel() and
"                               repeat#set(). Define
"                               s:RemoveLeadingDiffMarkers() for the special
"                               action.
"	007	16-Mar-2018	BUG: Pattern searches use very nomagic, but
"                               a:commentPattern is a normal magic pattern; need
"                               to switch back via \m.
"                               ENH: Add combination of diff + optional comment
"                               in
"                               AdvancedJoiners#CommentJoin#DiffAndOptionalComment().
"                               ENH: Support a:endOfLinePattern for removing
"                               optional ^M at the end of the previous line.
"                               Adapt s:SubstituteOnceInLine() to handle
"                               a:pattern matching before the cursor position,
"                               and detect and adapt the final cursor position
"                               to correct for the removal of that character(s).
"	006	12-Mar-2018	Refactoring: Extract
"                               AdvancedJoiners#CommentJoin#WithPattern() from
"                               AdvancedJoiners#CommentJoin#Join().
"                               ENH: Add gqJ mapping implementation in
"                               AdvancedJoiners#CommentJoin#Diff().
"                               Prefix repeat mappings with plugin name.
"	005	18-Jun-2013	Move s:GetCommentExpressions() into
"				ingo-library.
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

function! s:RemoveHyphen()
    if search('\V\w-\%# \s\*\%(\w\|-\)', 'bcnW', line('.'))
	normal! "_X
    endif
endfunction
function! s:SubstituteOnceInLine( pattern, replacement, isMoveLeft )
    let l:save_cursor = getpos('.')

    if ! search(a:pattern, 'cnW', line('.'))
	" Not on a:pattern; there might be a:endOfLinePattern before use that we
	" need to match:
	if search(a:pattern, 'bcW', line('.'))
	    " Yes, a:endOfLinePattern will be removed, too. Use its start
	    " position (note: no 'n' flag here!) for the final desired cursor
	    " position.
	    let l:desiredCursor = getpos('.')
	    " Restore the cursor (i.e. emulate the 'n' flag) so that a:pattern
	    " can match.
	    call setpos('.', l:save_cursor)
	    let l:save_cursor = l:desiredCursor
	else
	    " No on or after a:pattern.
	    return 0
	endif
    endif

    if a:isMoveLeft
	normal! h
    endif

    execute 'silent substitute/' . escape(a:pattern, '/') . '/' . escape(a:replacement, '/') . '/e'

    call setpos('.', l:save_cursor)
    return 1
endfunction
function! AdvancedJoiners#CommentJoin#WithPattern( endOfLinePattern, commentPattern, what, repeatMapping, mode, ... )
    " If something is joined with an empty line, no whitespace is inserted.
    " Since the cursor is positioned either on the whitespace (if the original
    " line did not end with whitespace) or after it, the whitespace before
    " a:commentPattern is optional, anyway, and handles that case, too.
    let l:joinedCommentPattern = a:endOfLinePattern . '\V\%# \?\m' . a:commentPattern

    let l:noCommentCnt = 0
    let l:isRemoveComments = 1
    let l:lineNum = AdvancedJoiners#RepeatFromMode(a:mode)
    let l:joinNum = l:lineNum - (a:mode ==# 'v' ? 1 : 0) " The last line isn't joined in visual mode.

    if ! search('\V\n\s\*\m' . a:commentPattern, 'cnW', line('.'))
	" Note: Search for /\n/ does not match in empty line, so explicitly
	" search for that corner case.
	if ! (empty(getline('.')) && search('\V\^\s\*\m' . a:commentPattern, 'cnW', line('.') + 1))
	    " The next line does not start with a comment string, so switch to "fuse
	    " mode" (i.e. joining and removing any whitespace) instead.
	    let l:joinedCommentPattern = '\%(^\%#\|' . a:endOfLinePattern . '\%# \s*\)'
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
    if a:0 | let l:didSubstitute = call(a:1, a:000[1:]) || l:didSubstitute | endif
    if l:didSubstitute | call histdel('search', -1) | endif " Clean up the search history.

    redraw
    if l:noCommentCnt > 0
	call ingo#msg#WarningMsg(l:joinNum > 1 ? printf('No %s in %d line%s', a:what, l:noCommentCnt, (l:noCommentCnt == 1 ? '' : 's')) : 'No ' . a:what . ' detected')
    else
	echomsg printf('%s%s %d %sline%s',
	\   (l:isRemoveComments ? 'Joined' : 'Fused'),
	\   (a:mode ==# 'v' ? ' together' : ''),
	\   l:joinCnt,
	\   (l:isRemoveComments ? a:what . ' ' : ''),
	\   (l:joinCnt == 1 ? '' : 's')
	\)
    endif

    silent! call       repeat#set(a:repeatMapping, l:joinNum)
    silent! call visualrepeat#set(a:repeatMapping, l:joinNum)
endfunction
function! AdvancedJoiners#CommentJoin#Comments( mode )
    let l:commentPattern = '\%(' . join(ingo#regexp#comments#FromSetting(), '\|') . '\)'
    call AdvancedJoiners#CommentJoin#WithPattern('', l:commentPattern, 'comment', "\<Plug>(AdvancedJoinersComment)", a:mode)
endfunction
let s:diffPatternKeepSeparatingWhitespace = '[+-]\%(\s*\ze\s\)\?'
let s:diffPatternAndWhitespace = '[+-]\s*'
let s:controlMPattern = '\r\?'
function! s:RemoveLeadingDiffMarkers( pattern )
    let l:save_cursor = getpos('.')
    execute 'silent substitute/^' . escape(a:pattern, '/') . '//e'
    silent substitute/\r\s*$//e
    call setpos('.', l:save_cursor)
    return 1
endfunction
function! AdvancedJoiners#CommentJoin#Diff( mode )
    call AdvancedJoiners#CommentJoin#WithPattern(
    \   s:controlMPattern, s:diffPatternKeepSeparatingWhitespace,
    \   'diff', "\<Plug>(AdvancedJoinersDiff)", a:mode,
    \   function('s:RemoveLeadingDiffMarkers'), s:diffPatternAndWhitespace
    \)
endfunction
function! AdvancedJoiners#CommentJoin#DiffAndOptionalComment( mode )
    let l:diffAndOptionalCommentPattern =
    \   '\%(' .
    \       join(
    \           map(ingo#regexp#comments#FromSetting(), "s:diffPatternAndWhitespace . '\\%(' . v:val . '\\)'") +
    \           [s:diffPatternKeepSeparatingWhitespace],
    \           '\|') .
    \   '\)'
    call AdvancedJoiners#CommentJoin#WithPattern(
    \   s:controlMPattern, l:diffAndOptionalCommentPattern,
    \   'diff [+ comment]', "\<Plug>(AdvancedJoinersDiffAndOptionalComment)", a:mode,
    \   function('s:RemoveLeadingDiffMarkers'), l:diffAndOptionalCommentPattern
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
