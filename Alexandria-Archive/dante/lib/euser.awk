BEGIN {FS="      	" ; SB="<" ; CB=">" }
{for (i = 3 ; i <= NF ; i++) 
	printf "%s ", $i
}
{print SB $1 CB}
