#!/bin/sh
#
# Autocreates the pre-load scripts for each level of the commentary
#
#This is a script that searches through a directory structure looking
# for "inf" "para" or "purg" directories.  If it finds any of them,
# it will create a preload script at that level, with the entire contents
# of each inf,para,or purg directory inserted into the proper field in the
# preload script.

# All numbered .e files are put into the COMM fields
# All other .e files are put in the PROEM fields

 
#obtain the full absolute path to this script
scriptname=`echo "$0" | sed 's/\(.*\)\/\([a-zA-Z0-9\._]\+\)/\2/'`
scriptpath=`echo "$0" | sed 's/\(.*\)\/\([a-zA-Z0-9\._]\+\)/\1/'`
cd $scriptpath
scriptpath=$PWD
cd $OLDPWD

#make sure we have 1 argument
if [ ! "$#" = "1" ];
then echo "Need a target directory."
exit
fi

#check that the target dir exists
if [ ! -d "$1" ];
then  echo "$1 is not a directory or does not exist"
exit
fi


echo "Current dir: $1"
cd $1 #move into the target directory

for infile in * #loop for each file in the current dir
do
  case "$infile" in

	"inf"|"purg"|"para") 
	    if [  "$infile" = "inf" ]
	    #get the contents of the inf directory and replace newlines
	    # spaces. Add quotes around the list
	    then infcommcontents=\"`ls "$infile" | egrep '[0-9]+.e' | tr "\n" ' '`\"
	    infproemcontents=\"`ls "$infile" | egrep '[^0-9]+.e' | tr "\n" ' '`\"
	    createpreloadfile="yes"
	    fi
	    

	if [ "$infile" = "purg" ]
	 then purgcommcontents=\"`ls "$infile" | egrep '[0-9]+.e' | tr "\n" ' '`\"
	    purgproemcontents=\"`ls "$infile" | egrep '[^0-9]+.e' | tr "\n" ' '`\"
	createpreloadfile="yes"
	fi

	if [ "$infile" = "para" ]
	 then paracommcontents=\"`ls "$infile" | egrep '[0-9]+.e' | tr "\n" ' '`\"
	    paraproemcontents=\"`ls "$infile" | egrep '[^0-9]+.e' | tr "\n" ' '`\"
	createpreloadfile="yes"
	fi
	;;
	*)
	  #recurse on directories
	  if [ -d "$infile" ]
	  then ${scriptpath}/${scriptname} ${PWD}/${infile}
	  fi
	  ;;
	esac

	if [ "$createpreloadfile" = "yes" ]
	then 
commentaryname=`pwd | sed 's/\(.*\)\/\([a-zA-Z0-9\._]\+\)/\2/'`

#This is the hardcoded text of the preload script.  If preload.2 moves then
#this script may have to be changed.

echo "#!/bin/sh

# Preload a commentary of the Dartmouth Dante Database.

#
# Commentary file lists for $commentaryname
#
INFPROEM=$infproemcontents
INFCOMM=$infcommcontents

PURGPROEM=$purgproemcontents
PURGCOMM=$purgcommcontents

PARAPROEM=$paraproemcontents
PARACOMM=$paracommcontents

#
# Invoke the common portion of this script
#
. preload.2" > preload
#don't forget to make the preload script executable
chmod +x preload
fi

done

