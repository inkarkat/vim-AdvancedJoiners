" Test unjoining of comma-separated list elements with formatoptions.

edit unjoin-list.txt
setlocal autoindent formatlistpat& formatlistpat+=\\|- formatoptions=tcron

execute "1normal \\uj, \<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
