" Test unjoining a duplicate assignment.

call setline(1, ['let foo =', 'let temp = "bar"', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

set virtualedit=onemore
1normal g#J
normal! mag`[yg`]g`arX
call vimtap#Is(@", ' "bar"', 'change marks are on the joined part')

call vimtest#SaveOut()
call vimtest#Quit()
