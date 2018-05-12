" AdvancedJoiners.vim: More ways to (un-)join lines.
"
" DEPENDENCIES:
"   - ingo/cmdargs.vim autoload script
"   - ingo/err.vim autoload script
"   - AdvancedJoiners/Comments.vim autoload script
"   - AdvancedJoiners/Folds.vim autoload script
"   - AdvancedJoiners/QueryJoin.vim autoload script
"   - AdvancedJoiners/QueryUnjoin.vim autoload script
"
" Copyright: (C) 2005-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	007	16-Mar-2018	ENH: Add combination gcqJ = gcJ + gqJ.
"	006	12-Mar-2018	Add gqJ mapping to join without diff quirks.
"	005	06-Mar-2018	Add gsJ mapping to join without any whitespace
"                               in between.
"	004	05-Mar-2018	Add :Join; it was documented, but not yet
"				implemented :-(
"				Adapt <Leader>J / <Leader>uj mappings to what's
"				documented, and also define (upper-case)
"				variants for the non-querying repeat mappings.
"				Need to pass a:repeatMapping to
"				AdvancedJoiners#QueryJoin#Join(), as it is used
"				with different a:isKeepIndent values by
"				<Leader>j and <Leader>gj.
"				Align Plug-mapping names and consistently prefix
"				with AdvancedJoiners.
"	003	23-Dec-2016	Rename gJ to gcJ, so that it doesn't override
"				the built-in gJ any longer.
"	002	08-Jun-2014	Move in :JoinFolded from ingocommands.vim.
"	001	07-Feb-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_AdvancedJoiners') || (v:version < 700)
    finish
endif
let g:loaded_AdvancedJoiners = 1

"- commands --------------------------------------------------------------------

command! -bang -range=% -nargs=? JoinFolded call setline(<line1>, getline(<line1>)) | if ! AdvancedJoiners#Folds#Join(<bang>0, <line1>, <line2>, ingo#cmdargs#GetStringExpr(<q-args>)) | echoerr ingo#err#Get() | endif
command! -bang -range   -nargs=? Join       call setline(<line1>, getline(<line1>)) | if ! AdvancedJoiners#QueryJoin#JoinCommand(<bang>0, <line1>, <line2>, <q-args>) | echoerr ingo#err#Get() | endif


"- mappings --------------------------------------------------------------------

nnoremap <silent> <Plug>(AdvancedJoinersActionCounted) :<C-u>execute 'normal!' (v:count1 + 1) . 'J'<CR>
if ! hasmapto('<Plug>(AdvancedJoinersActionCounted)', 'n')
    nmap J <Plug>(AdvancedJoinersActionCounted)
endif


nnoremap <silent> <Plug>(AdvancedJoinersComment) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Comments('n')<CR>
vnoremap <silent> <Plug>(AdvancedJoinersComment) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Comments('v')<CR>
if ! hasmapto('<Plug>(AdvancedJoinersComment)', 'n')
    nmap gcJ <Plug>(AdvancedJoinersComment)
endif
if ! hasmapto('<Plug>(AdvancedJoinersComment)', 'x')
    xmap gcJ <Plug>(AdvancedJoinersComment)
endif

nnoremap <silent> <Plug>(AdvancedJoinersDiff) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Diff('n')<CR>
vnoremap <silent> <Plug>(AdvancedJoinersDiff) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Diff('v')<CR>
if ! hasmapto('<Plug>(AdvancedJoinersDiff)', 'n')
    nmap gqJ <Plug>(AdvancedJoinersDiff)
endif
if ! hasmapto('<Plug>(AdvancedJoinersDiff)', 'x')
    xmap gqJ <Plug>(AdvancedJoinersDiff)
endif

nnoremap <silent> <Plug>(AdvancedJoinersDiffAndOptionalComment) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#DiffAndOptionalComment('n')<CR>
vnoremap <silent> <Plug>(AdvancedJoinersDiffAndOptionalComment) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#DiffAndOptionalComment('v')<CR>
if ! hasmapto('<Plug>(AdvancedJoinersDiffAndOptionalComment)', 'n')
    nmap gcqJ <Plug>(AdvancedJoinersDiffAndOptionalComment)
endif
if ! hasmapto('<Plug>(AdvancedJoinersDiffAndOptionalComment)', 'x')
    xmap gcqJ <Plug>(AdvancedJoinersDiffAndOptionalComment)
endif

nnoremap <silent> <Plug>(AdvancedJoinersNoWhitespace) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#JoinWithSeparator(0, 'n', '', "\<lt>Plug>(AdvancedJoinersNoWhitespace)")<CR>
vnoremap <silent> <Plug>(AdvancedJoinersNoWhitespace) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#JoinWithSeparator(0, 'v', '', "\<lt>Plug>(AdvancedJoinersNoWhitespace)")<CR>
if ! hasmapto('<Plug>(AdvancedJoinersNoWhitespace)', 'n')
    nmap gsJ <Plug>(AdvancedJoinersNoWhitespace)
endif
if ! hasmapto('<Plug>(AdvancedJoinersNoWhitespace)', 'x')
    xmap gsJ <Plug>(AdvancedJoinersNoWhitespace)
endif


nnoremap <silent> <Plug>(AdvancedJoinersQuery)  :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'n', 1, "\<lt>Plug>(AdvancedJoinersRepeat)")<CR>
vnoremap <silent> <Plug>(AdvancedJoinersQuery)  :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'v', 1, "\<lt>Plug>(AdvancedJoinersRepeat)")<CR>
nnoremap <silent> <Plug>(AdvancedJoinersRepeat) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'n', 0, "\<lt>Plug>(AdvancedJoinersRepeat)")<CR>
vnoremap <silent> <Plug>(AdvancedJoinersRepeat) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'v', 0, "\<lt>Plug>(AdvancedJoinersRepeat)")<CR>
if ! hasmapto('<Plug>(AdvancedJoinersQuery)', 'n')
    nmap <Leader>j <Plug>(AdvancedJoinersQuery)
endif
if ! hasmapto('<Plug>(AdvancedJoinersQuery)', 'x')
    xmap <Leader>j <Plug>(AdvancedJoinersQuery)
endif
if ! hasmapto('<Plug>(AdvancedJoinersRepeat)', 'n')
    nmap <Leader>J <Plug>(AdvancedJoinersRepeat)
endif
if ! hasmapto('<Plug>(AdvancedJoinersRepeat)', 'x')
    xmap <Leader>J <Plug>(AdvancedJoinersRepeat)
endif

nnoremap <silent> <Plug>(AdvancedJoinersQueryKeepIndent)  :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'n', 1, "\<lt>Plug>(AdvancedJoinersRepeatKeepIndent)")<CR>
vnoremap <silent> <Plug>(AdvancedJoinersQueryKeepIndent)  :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'v', 1, "\<lt>Plug>(AdvancedJoinersRepeatKeepIndent)")<CR>
nnoremap <silent> <Plug>(AdvancedJoinersRepeatKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'n', 0, "\<lt>Plug>(AdvancedJoinersRepeatKeepIndent)")<CR>
vnoremap <silent> <Plug>(AdvancedJoinersRepeatKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'v', 0, "\<lt>Plug>(AdvancedJoinersRepeatKeepIndent)")<CR>
if ! hasmapto('<Plug>(AdvancedJoinersQueryKeepIndent)', 'n')
    nmap <Leader>gj <Plug>(AdvancedJoinersQueryKeepIndent)
endif
if ! hasmapto('<Plug>(AdvancedJoinersQueryKeepIndent)', 'x')
    xmap <Leader>gj <Plug>(AdvancedJoinersQueryKeepIndent)
endif
if ! hasmapto('<Plug>(AdvancedJoinersRepeatKeepIndent)', 'n')
    nmap <Leader>gJ <Plug>(AdvancedJoinersRepeatKeepIndent)
endif
if ! hasmapto('<Plug>(AdvancedJoinersRepeatKeepIndent)', 'x')
    xmap <Leader>gJ <Plug>(AdvancedJoinersRepeatKeepIndent)
endif


nnoremap <silent> <Plug>(AdvancedJoinersUnjoin)       :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 1)<CR>
vnoremap <silent> <Plug>(AdvancedJoinersUnjoin)       :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 1)<CR>
nnoremap <silent> <Plug>(AdvancedJoinersUnjoinRepeat) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 0)<CR>
vnoremap <silent> <Plug>(AdvancedJoinersUnjoinRepeat) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 0)<CR>
if ! hasmapto('<Plug>(AdvancedJoinersUnjoin)', 'n')
    nmap <Leader>uj <Plug>(AdvancedJoinersUnjoin)
endif
if ! hasmapto('<Plug>(AdvancedJoinersUnjoin)', 'x')
    xmap <Leader>uj <Plug>(AdvancedJoinersUnjoin)
endif
if ! hasmapto('<Plug>(AdvancedJoinersUnjoinRepeat)', 'n')
    nmap <Leader>uJ <Plug>(AdvancedJoinersUnjoinRepeat)
endif
if ! hasmapto('<Plug>(AdvancedJoinersUnjoinRepeat)', 'x')
    xmap <Leader>uJ <Plug>(AdvancedJoinersUnjoinRepeat)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
