##########################################################################
#
#	Reformat Divine Comedy for BRS loading
#
#  "last" counts the three lines in a triplet: 1,2,3,1,2,3,etc.
#
#  "lineno" and "endl" and the beginning and ending line number
#   of each triplet
#
##########################################################################
#
#  Skip blank lines
#
/^ *$/	{ next }
#
# Canto title lines
#
$2 ~ /CANTO/	{
	if ($1 ~ /INF/) {
		CTCA = "10-Inferno"
		CTCATAG = "10"
	}
	else if ($1 ~ /PURG/) {
		CTCA = "20-Purgatorio"
		CTCATAG = "20"
	}
	else if ($1 ~ /PARA/) {
		CTCA = "30-Paradiso"
		CTCATAG = "30"
	}
	CNTO = $3
	lineno = 1
	last = 0
	next
	}
#
#  Last line of triplet.  These have |<line number> on them.
#
/\|[0-9]*$/	{
	split($0,field,"|")
	line[++last] = field[1]
	endl = field[2]
	print "..COMM: Divina Commedia"
	print "..AUTH: Dante Alighieri"
	print "..LANG: Italian"
	print "..DTYP: P"
	print "..PUBD: 1320"
	print "..ATTR: copyright"
	print "..LODD:"
	print "..CTCA: " CTCA
	print "..CNTO: " CNTO
	print "..LINE: " lineno
	print "..ENDL: " endl
	printf "..LRNG:"
	for (i = lineno; i<=endl; i++)
		printf " %d", i
	printf "\n"
	print "..REFS:"
	for (i = lineno; i<=endl; i++)
		print "IT-A" CTCATAG "-O" CNTO "-L" i " A" CTCATAG "-O" CNTO "-L" i
	print "..TEXT:"
	for (i = 1; i<=last; i++)
		print line[i]
	lineno = endl + 1
	last = 0
	next
	}
#
#  Plain text lines
#
	{ line[++last] = $0 }
