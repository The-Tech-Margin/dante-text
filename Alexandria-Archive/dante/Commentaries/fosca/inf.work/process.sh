#!/bin/sh
#
#  Translate the character 226 into  *  and then into " -- ".
#  John Wallace 2/2004
#
#  Hand fix needs to be done on 11.2 where there is one "*" in the original
#       lat. volg.  *^rubja~, class. ^rubea~
#
for i in *.e
do
  echo "processing $i"
  tr '\226' \* < $i | sed 's/\*/ -- /g' > $i.new
  cp -f $i.new ../inf/$i
  echo ".................  $i done"
  echo
done
