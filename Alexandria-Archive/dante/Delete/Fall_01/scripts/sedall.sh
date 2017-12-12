#!/bin/sh
#
#
#

find ./ -name "*.txt"  -type f -print | egrep -v "ascii" > filelist

while read file
do
	
	echo  $file
	sed -f space.sed < $file > ${file}.out


done < filelist



#
# Space.sed
#
#s/|       /	|/g             - Change   |white space   to   tab|
#s/       /	/g		- Change   whitespace     to   tab
#s/\.  ~/\.\~  /g		- Left justify the  ~
#s/^|[0-9][0-9]*-[0-9][0-9]/	&/ - Add a tab to lines that have the form |1-15
