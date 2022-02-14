" Test unjoining duplicate text on the last line.

call setline(1, ['let foo =', 'let temp = "bar"', 'EOF'])

$normal g#J

call vimtest#SaveOut()
call vimtest#Quit()
