" Test unjoining a duplicate non-keyword text

call setline(1, ['this will have be...', '(further stuff omitted)...en great', 'EOF'])

1normal g#J

call vimtest#SaveOut()
call vimtest#Quit()
