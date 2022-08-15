" Test joining of count lines of line-continuation.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

edit join-linecontinuation.txt

50normal 2g\J
38normal 2g\J
31normal 2g\J
27normal 1g\J
19normal 2g\J
15normal 1g\J
6normal 4g\J

call vimtest#SaveOut()
call vimtest#Quit()
