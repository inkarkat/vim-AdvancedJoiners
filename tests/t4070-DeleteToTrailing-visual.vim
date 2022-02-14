" Test unjoining a selection of duplicate multi-line assignment.

call setline(1, ['let foo =', 'let temp = bar', 'let temp2 = quux', 'let t3 = lulli', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

set virtualedit=onemore
1normal V3jg#J
normal! mag`[yg`]g`arX
call vimtap#Is(@", ' bar quux lulli', 'change marks are on all joined parts')

call vimtest#SaveOut()
call vimtest#Quit()
