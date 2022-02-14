" Test unjoining a duplicate multi-line with assignment only on one line.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call setline(1, ['let foo =', 'let temp = bar', '(uninteresting)', '(nothing here)', '(boring)', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

1normal 4g#J

call vimtap#Is(@", 'let temp =', 'removed single lead-in is put characterwise into the default register')

call vimtest#SaveOut()
call vimtest#Quit()
