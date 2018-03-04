" AdvancedJoiners.vim: More ways to (un-)join lines.
"
" DEPENDENCIES:
"   - ingo/cmdargs.vim autoload script
"   - ingo/err.vim autoload script
"   - AdvancedJoiners/CommentJoin.vim autoload script
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
"	004	05-Mar-2018	Add :Join; it was documented, but not yet
"                               implemented :-(
"				Adapt <Leader>J / <Leader>uj mappings to what's
"				documented, and also define (upper-case)
"				variants for the non-querying repeat mappings.
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

nnoremap <silent> <Plug>(ActionCountedJoin) :<C-u>execute 'normal!' (v:count1 + 1) . 'J'<CR>
if ! hasmapto('<Plug>(ActionCountedJoin)', 'n')
    nmap J <Plug>(ActionCountedJoin)
endif


nnoremap <silent> <Plug>(CommentJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Join('n')<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also reduced by the command.
vnoremap <silent> <Plug>(CommentJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Join('v')<CR>
if ! hasmapto('<Plug>(CommentJoin)', 'n')
    nmap gcJ <Plug>(CommentJoin)
endif
if ! hasmapto('<Plug>(CommentJoin)', 'x')
    xmap gcJ <Plug>(CommentJoin)
endif


" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also reduced by the command.
nnoremap <silent> <Plug>(QueryJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'n', 1)<CR>
xnoremap <silent> <Plug>(QueryJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'v', 1)<CR>
nnoremap <silent> <Plug>(RepeatQueryJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'n', 0)<CR>
vnoremap <silent> <Plug>(RepeatQueryJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(0, 'v', 0)<CR>
if ! hasmapto('<Plug>(QueryJoin)', 'n')
    nmap <Leader>j <Plug>(QueryJoin)
endif
if ! hasmapto('<Plug>(QueryJoin)', 'x')
    xmap <Leader>j <Plug>(QueryJoin)
endif
if ! hasmapto('<Plug>(RepeatQueryJoin)', 'n')
    nmap <Leader>J <Plug>(RepeatQueryJoin)
endif
if ! hasmapto('<Plug>(RepeatQueryJoin)', 'x')
    xmap <Leader>J <Plug>(RepeatQueryJoin)
endif

nnoremap <silent> <Plug>(RepeatQueryJoinKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'n', 0)<CR>
vnoremap <silent> <Plug>(RepeatQueryJoinKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'v', 0)<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also reduced by the command.
nnoremap <silent> <Plug>(QueryJoinKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'n', 1)<CR>
xnoremap <silent> <Plug>(QueryJoinKeepIndent) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join(1, 'v', 1)<CR>
if ! hasmapto('<Plug>(QueryJoinKeepIndent)', 'n')
    nmap <Leader>gj <Plug>(QueryJoinKeepIndent)
endif
if ! hasmapto('<Plug>(QueryJoinKeepIndent)', 'x')
    xmap <Leader>gj <Plug>(QueryJoinKeepIndent)
endif
if ! hasmapto('<Plug>(RepeatQueryJoinKeepIndent)', 'n')
    nmap <Leader>gJ <Plug>(RepeatQueryJoinKeepIndent)
endif
if ! hasmapto('<Plug>(RepeatQueryJoinKeepIndent)', 'x')
    xmap <Leader>gJ <Plug>(RepeatQueryJoinKeepIndent)
endif


nnoremap <silent> <Plug>(RepeatQueryUnjoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 0)<CR>
vnoremap <silent> <Plug>(RepeatQueryUnjoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 0)<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also multiplied by the command.
nnoremap <silent> <Plug>(QueryUnjoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 1)<CR>
xnoremap <silent> <Plug>(QueryUnjoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 1)<CR>
if ! hasmapto('<Plug>(QueryUnjoin)', 'n')
    nmap <Leader>uj <Plug>(QueryUnjoin)
endif
if ! hasmapto('<Plug>(QueryUnjoin)', 'x')
    xmap <Leader>uj <Plug>(QueryUnjoin)
endif
if ! hasmapto('<Plug>(RepeatQueryUnjoin)', 'n')
    nmap <Leader>uJ <Plug>(RepeatQueryUnjoin)
endif
if ! hasmapto('<Plug>(RepeatQueryUnjoin)', 'x')
    xmap <Leader>uJ <Plug>(RepeatQueryUnjoin)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
