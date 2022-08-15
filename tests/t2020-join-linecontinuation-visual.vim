" Test joining of selected lines of line-continuation.

edit join-linecontinuation.txt

50normal V2jg\J
38normal V2jg\J
31normal V2jg\J
27normal Vjg\J
19normal V2jg\J
15normal Vjg\J
6normal V4jg\J

call vimtest#SaveOut()
call vimtest#Quit()
