#	checkform.awk - awk program to check a Dante Project formatted file
#		for consistency in indentation styles.  Checks for paragraphs
#		that begin with spaces instead of tabs, indented sections
#		that contain tabs instead of spaces, and indenting in
#		inappropriate places.  Also attempts to warn of potential
#		problems with single-line units.  A paragraph is considered
#		to be a block of text separarated by at least one blank line on
#		each side of itself.
#	CAVEATS-1) This program writes its findings on stdout, so it is NOT a
#			filter and should NOT be used to pipe its output
#			anywhere except to collect the diagnostics
#			in a file.
#		2) This program will only run under "new awk", which is invoked
#			by the command "nawk" and not "awk."  This caveat will
#			disappear at some point when new awk becomes the real
#			awk.
#	Written 2/23/89 by JMA(with no assistance from anybody, so there!)

BEGIN { RS = "" ; FS = "\n" 
	fname = FILENAME
	print "Checking file " fname
}
{if (fname != FILENAME) {
	fname = FILENAME
	print "Checking file " fname
}}

NF == 1 && /^	[^|]/ && ! /^     / {
	print "Warning: Single line paragraph"
	print $0
	print OFS
	next
}

/^	/ && NF > 1 {
	i = 2
	if (index($i,"	") == 1) {
		errmsg = "Error: tabs used for indenting"
		printerr(errmsg, i) 
	}
	else {
		for (++i; i <= NF ; i++) {
			if (index($i,"    ") ==1 || index($i,"	") == 1){
				errmsg = "Error: bad indent in paragraph"
				printerr(errmsg, i)
				next
			}
		}
	}
}

/^     / && NF > 1 {
	i = 2
	if (index($i," ") != 1 && index($i,"	") != 1){
		errmsg = "Error: Space used as Paragraph head"
		printerr(errmsg,i)
	}
	else {
		for ( ++i; i <= NF; i++) {
			if (index($i, "	") == 1){
				errmsg = "Error: Tab used in middle of indenting"
				printerr(errmsg, i)
				next
			}
			else if (index($i, " ") != 1) {
				errmsg = "Error: Leading spaces missing in indenting"
				printerr(errmsg, i)
				next
			}
		}
	}
	next
}

/^  */ && NF > 1 {
	i = 2
	errmsg = "Error: Incorrect spacing at head of indenting/paragraph"
	printerr(errmsg, i)
	next
}

/^[^ 	]/ && NF > 1 {
	for (i = 2; i <= NF; i++) {
		if (index($i," ") ==1 || index($i, "	") == 1) {
			errmsg = "Error: Bad indent in section"
			printerr(errmsg, i)
			next
		}
	}
}
	
function printerr(msg, line) {
	print msg
	for (j = line - 1 ; (j <= line +2) && (j <= NF) ; j++) {
		print $j
	}
	print OFS
}
