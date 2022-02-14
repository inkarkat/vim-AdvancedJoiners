" Test unjoining a duplicate multi-line with no assignment on the second line.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call vimtest#StartTap()
call vimtap#Plan(1)

call setline(1, ['let foo =', '(uninteresting)', 'let temp = bar', 'let t3 = lulli', '(boring)', 'EOF'])

call vimtap#err#Errors("Following line does not contain '='", '1normal 4g#J', 'error when following line does not contain =')

call vimtest#SaveOut()
call vimtest#Quit()
