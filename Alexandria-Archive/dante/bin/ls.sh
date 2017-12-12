#!/bin/csh -f

# Do a formatted ls -lR of the dante home directory

cd ~dante
foreach DIR (*)
	if (-d $DIR) then
		ls -lR $DIR | pr -2 -w132 -h $DIR
	endif
end
