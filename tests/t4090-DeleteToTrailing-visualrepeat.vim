" Test repeat of unjoining a selection of duplicate assignment.

call setline(1, ['let foo =', 'let temp = "bar"', 'filler', 'this is 7 *', 'why 42 * 11', 'for 3 *6', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)
set virtualedit=onemore

4normal V2jg#J

1normal Vj.
normal! mag`[yg`]g`arX
call vimtap#Is(@", ' "bar"', 'change marks are on the joined part')

call vimtest#SaveOut()
call vimtest#Quit()
