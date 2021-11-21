" Test unjoining of c code.

edit unjoin-c.txt
set cindent

execute "3normal \\uj,;\\zs \\|{\\zs \\|}\\zs \\| \\ze#\\||\<CR>"
execute "1normal \\uj{\\zs \\|}\\zs \<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
