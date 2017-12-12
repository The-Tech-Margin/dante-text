# Find newline followed by bold and tab it
/^$/{
N
s/\n|/\
	|/
}

