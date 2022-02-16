" Test unjoining duplicate text on the last line.

call setline(1, ['let foo =', 'let temp = "bar"', 'EOF'])

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#err#Errors("Following line does not contain 'EOF'", '$normal g#J', 'following line error on last line')

call vimtest#SaveOut()
call vimtest#Quit()
