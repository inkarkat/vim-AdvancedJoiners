" Test repeat of joining of line-continuation.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

edit join-linecontinuation.txt

25normal 3g\J
19normal .

call vimtest#SaveOut()
call vimtest#Quit()
