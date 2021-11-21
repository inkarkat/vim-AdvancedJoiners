" Test unjoining of comma-separated elements keeping the comma.

edit unjoin-comma.txt
set autoindent

execute "9normal \\uj,\\zs\<CR>"
execute "7normal \\uj,\\zs\<CR>"
execute "5normal \\uj,\\zs\<CR>"
execute "3normal \\uj,\\zs\<CR>"
execute "1normal \\uj,\\zs\<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
