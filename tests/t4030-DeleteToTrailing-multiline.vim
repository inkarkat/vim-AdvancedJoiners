" Test unjoining a duplicate multi-line assignment.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call setline(1, ['let foo =', 'let temp = bar', 'let temp2 = quux', 'let t3 = lulli', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(2)

set virtualedit=onemore
1normal "a3g#J
normal! mag`[yg`]g`arX

call vimtap#Is(@", ' bar quux lulli', 'change marks are on all joined parts')
call vimtap#Is(@a, "let temp =\nlet temp2 =\nlet t3 =\n", 'removed lead-ins are put into the specified register')

call vimtest#SaveOut()
call vimtest#Quit()
