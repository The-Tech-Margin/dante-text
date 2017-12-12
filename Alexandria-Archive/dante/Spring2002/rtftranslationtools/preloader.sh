#!/bin/sh
#
#  Uses the dante preload script
#
for targetdir in *
do
	if [ -d $targetdir ] ;
	then
	cd ${targetdir}
	preload > preload.out
	cd ..
	fi
done
