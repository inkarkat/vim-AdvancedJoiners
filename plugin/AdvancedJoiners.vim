" AdvancedJoiners.vim: More ways to (un-)join lines.
"
" DEPENDENCIES:
"   - AdvancedJoiners/CommentJoin.vim autoload script
"   - AdvancedJoiners/QueryJoin.vim autoload script
"   - AdvancedJoiners/QueryUnjoin.vim autoload script
"
" Copyright: (C) 2005-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	07-Feb-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_AdvancedJoiners') || (v:version < 700)
    finish
endif
let g:loaded_AdvancedJoiners = 1

nnoremap <silent> J :<C-u>execute 'normal!' (v:count1 + 1) . 'J'<CR>

nnoremap <silent> <Plug>(CommentJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Join('n')<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also reduced by the command.
nmap gJ <Plug>(CommentJoin)
vnoremap <silent> <Plug>(CommentJoin) :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#CommentJoin#Join('v')<CR>
xmap gJ <Plug>(CommentJoin)

nnoremap <Plug>(RepeatQueryJoin) :<C-u>call AdvancedJoiners#QueryJoin#Join('n', 0)<CR>
vnoremap <Plug>(RepeatQueryJoin) :<C-u>call AdvancedJoiners#QueryJoin#Join('v', 0)<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also reduced by the command.
nnoremap <silent> <Leader>J :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join('n', 1)<CR>
xnoremap <silent> <Leader>J :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryJoin#Join('v', 1)<CR>

nnoremap <silent> <Plug>(RepeatQueryUnjoin) :<C-u>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 0)<CR>
vnoremap <silent> <Plug>(RepeatQueryUnjoin) :<C-u>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 0)<CR>
" Repeat not possible in visual mode, as the command would be executed once per
" line, but the lines are also multiplied by the command.
nnoremap <silent> <Leader>uj :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('n', 1)<CR>
xnoremap <silent> <Leader>uj :<C-u>call setline('.', getline('.'))<Bar>call AdvancedJoiners#QueryUnjoin#Unjoin('v', 1)<CR>

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
