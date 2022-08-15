" Test joining of line-continuation.

edit join-linecontinuation.txt

global/^--/+1 normal g\J

call vimtest#SaveOut()
call vimtest#Quit()
