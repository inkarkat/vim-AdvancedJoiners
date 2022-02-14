" Test unjoining a duplicate keyword text

call setline(1, ['call Foo(arg1, arg2', 'call Bar(arg1, arg2, arg3)', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(2)

let @" = ''
let @a = ''
1normal "ag#J

call vimtap#Is(@a, 'call Bar(arg1, arg2', 'removed lead-in is put into the specified register')
call vimtap#Is(@", '', 'default register is unchanged')

call vimtest#SaveOut()
call vimtest#Quit()
