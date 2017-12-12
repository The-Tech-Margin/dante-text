BEGIN {suffix = ".k"
	filename = "00.k"}

($1 ~ /%c/) {
	close(filename)
	++counter
	filename = sprintf("%02d%2s", counter, suffix)
	next
}
($1 !~ /%c/) {
	{print $0 > filename}
}
