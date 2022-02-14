" Test unjoining a duplicate multi-line with assignment only on some lines.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call setline(1, ['let foo =', 'let temp = bar', '(uninteresting)', 'let t3 = lulli', '(boring)', 'EOF'])

1normal 4g#J

call vimtest#SaveOut()
call vimtest#Quit()
