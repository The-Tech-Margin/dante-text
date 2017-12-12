BEGIN {suffix = ".e"
	filename = "00.e"}

($1 ~ /\|CANTO/) {
	close(filename)
	++counter
	filename = sprintf("%02d%2s", counter, suffix)
	print $0 > filename
	next
}
($1 !~ /\|CANTO/) {
	{print $0 > filename}
}
