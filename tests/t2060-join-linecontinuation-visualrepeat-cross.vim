" Test repeat of joining of line-continuation.

edit join-linecontinuation.txt

25normal V2jg\J
19normal .

call vimtest#SaveOut()
call vimtest#Quit()
