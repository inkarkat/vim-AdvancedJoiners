" Test unjoining with no trailing text.

call setline(1, ["   \t   \t", 'let temp = "bar"', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#err#Errors('No trailing text found', '1normal g#J', 'description')

call vimtest#SaveOut()
call vimtest#Quit()
