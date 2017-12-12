BEGIN {suffix = ".k"
	filename = "00.k"}

($4 ~ /proemio/) {
	close(filename)
	++counter
	filename = sprintf("%02d%2s", counter, suffix)
	print "|Proemio~" > filename
	next
}
($4 !~ /proemio/) {
	{print $0 > filename}
}
