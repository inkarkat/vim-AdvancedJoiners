" Test unjoining of comma-separated elements.

edit unjoin-comma.txt
set autoindent

execute "9normal \\uj,\<CR>"
execute "7normal \\uj,\<CR>"
execute "5normal \\uj,\<CR>"
execute "3normal \\uj,\<CR>"
execute "1normal \\uj,\<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
