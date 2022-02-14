" Test repeat of unjoining a selection of duplicate assignment in normal mode.

call setline(1, ['let foo =', 'let temp = "bar"', 'filler', 'this is 7 *', 'why 42 * 11', 'for 3 *6', 'EOF'])

4normal V2jg#J
1normal .

call vimtest#SaveOut()
call vimtest#Quit()
