" Test prevention of endless recursion from comment leader.

edit unjoin-comments.txt
setlocal comments& formatoptions=tcqr

3substitute/:/*/g
execute "3normal \\uj\\ze\\*\<CR>"
execute "1normal \\uj \\(be\\|or\\)\\zs \\| \\ze\\*\<CR>"

call vimtest#SaveOut()
call vimtest#Quit()
