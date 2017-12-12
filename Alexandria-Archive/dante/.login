if ( $term == "network") then
	set	term=`tset - -I -Q -m :\?vt200`
	stty rows 24 cols 80
else
	stty dec new cr0
	tset -I -Q
endif
stty	kill ^X
cat	.dmotd
