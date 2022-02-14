" Test repeat of unjoining a duplicate assignment.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call setline(1, ['let foo =', 'let temp = "bar"', 'filler', 'this is 7 *', 'why 42 * 11', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)
set virtualedit=onemore

4normal g#J

1normal .
normal! mag`[yg`]g`arX
call vimtap#Is(@", ' "bar"', 'change marks are on the joined part')

call vimtest#SaveOut()
call vimtest#Quit()
