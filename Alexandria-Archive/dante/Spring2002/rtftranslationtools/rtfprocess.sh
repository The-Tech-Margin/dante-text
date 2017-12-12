#!/bin/sh
#  
# Author:Lars Lynch 
# Tool for translating RTF files in a directory and subdirectories
# This script employs the Word/RTFtoHTML/XML converter by Logictran
# Step 1:  This script runs over every .rtf file with the logictran converter
#          and saves the ouput as a .rtf.txt file
# Step 2:  The outputfile is then parsed down to its canto number and fed
#          through 2 sed scripts that eat white space, fix tabs, correct
#          character translations and indent paragraphs.
# Step 3:  The output from these scripts is saved as 01.e, 02.e, etc.

#obtain absolute pathname of this script
scriptname=`echo "$0" | sed 's/\(.*\)\/\([a-zA-Z0-9\._]\+\)/\2/'`
scriptpath=`echo "$0" | sed 's/\(.*\)\/\([a-zA-Z0-9\._]\+\)/\1/'`
cd $scriptpath
scriptpath=$PWD
cd $OLDPWD

convertername=~/r2net/r2netcmd #Logictran converter 
convertertrn=${scriptpath}/ascii.trn #Where to find the translation files
sedscript1=${scriptpath}/eatwhite.sed #first sed script
sedscript2=${scriptpath}/findpara.sed #second sed script
sedscript3=${scriptpath}/extralf.sed #third sed script


#make sure we have 2 arguments, a source dir and a target dir
if [ ! "$#" = "2" ];
then echo "Need a source directory and a target directory."
exit
fi

#check that the source dir exists
if [ ! -d $1 ];
then  echo "$1 is not a directory or does not exist"
exit
fi

#if the target dir doesn't exist, create it.
targetdir=$2
if [ ! -e "$targetdir" ];
	then mkdir $targetdir
fi
realtargetdir=$( cd "$targetdir" ; pwd ) #get the absolute target path


echo "Target dir: $realtargetdir"
echo "Current dir: $1"
cd $1 #move into the source directory

for infile in * #loop for each file in the current dir
do
  
	#if we have a dir, recursively call the script with $infile as
	#the source dir and a mirror dir in the target dir
	if [ -d "$infile" ];
	then echo "Working in $infile"
        ${scriptpath}/${scriptname} ${PWD}/${infile} ${realtargetdir}/${infile}
	fi

	#Here's where the heavy lifting begins for rtf files
	if expr $infile : .*\\.rtf >> /dev/null
	then echo "Processing $infile"

	#Use the Logictran rtf converter
	${convertername} -DTrnFile=${convertertrn} -DOutfileName=${realtargetdir}/${infile}.txt ${infile} 

	#reduce filenames with numbers to just the number; leave others alone
	numbername=`echo "$infile" | sed 's/\([a-zA-Z_\.]*\)\([0-9]\+\)\([a-zA-Z_\.]*\)/\2/' | sed 's/\([a-zA-Z_\.]*\)\(\.rtf$\)/\1/'`

	#run the output of the Logictran converter through the sedscripts and
	# output it to cantonumber.e or filename.e
	sed -f ${sedscript1} ${targetdir}/${infile}.txt | sed -f ${sedscript2} | sed -f ${sedscript3} | fold -bs -w 72 > ${targetdir}/${numbername}.e
	
	#clean up
	rm ${targetdir}/${infile}.txt
	fi
done


