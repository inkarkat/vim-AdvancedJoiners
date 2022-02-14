" Test unjoining a duplicate non-keyword text

call setline(1, ['this will have be...', '(further stuff omitted)...en great', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

let @" = ''
1normal g#J

call vimtap#Is(@", '(further stuff omitted)...', 'removed lead-in is put into the default register')

call vimtest#SaveOut()
call vimtest#Quit()
