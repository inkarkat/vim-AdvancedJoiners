" Test unjoining of comments.

edit unjoin-comments.txt
setlocal comments& formatoptions=tcqr

"execute "3normal \\uj \\(be\\|or\\)\\zs \\| \\ze\\*\<CR>"
execute "3normal \\uj:\<CR>"
execute "1normal \\uj()\\zs \<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
