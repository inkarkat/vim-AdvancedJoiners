" Test unjoining a duplicate keyword text

call setline(1, ['call Foo(arg1, arg2', 'call Bar(arg1, arg2, arg3)', 'EOF'])

1normal g#J

call vimtest#SaveOut()
call vimtest#Quit()
