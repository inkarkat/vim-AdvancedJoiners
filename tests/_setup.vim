runtime plugin/AdvancedJoiners.vim
call vimtest#AddDependency('vim-ingo-library')

if g:runVimTest =~# '-\%(visual\)\?repeat[.-]'
    call vimtest#AddDependency('vim-repeat')
endif
if g:runVimTest =~# '-visualrepeat[.-]'
    call vimtest#AddDependency('vim-visualrepeat')
endif
