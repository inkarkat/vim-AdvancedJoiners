" AdvancedJoiners/Folds.vim: Join folded lines.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2014-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! AdvancedJoiners#Folds#Join( isKeepSpace, startLnum, endLnum, separator )
    let [l:foldNum, l:joinCnt] = ingo#join#FoldedLines(a:isKeepSpace, a:startLnum, a:endLnum, a:separator)
    if empty(l:foldNum)
	call ingo#err#Set('No folds found')
	return 0
    elseif l:joinCnt > &report
	echo printf('%d line%s in %d fold%s joined', l:joinCnt, (l:joinCnt == 1 ? '' : 's'), l:foldNum, (l:foldNum == 1 ? '' : 's'))
    endif
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
