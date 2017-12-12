#Eat large amounts of white space tabs
#s/    *//g
#
#Eat white space after |
#s/|\( *\)/\1|/g
#      space tab

s/|\([ 	]*\)\(.*\)\([ 	]*\)~/\1|\2~\3/g

#
#Eat white space after ^

#s/\^\([ 	]*\)\(.*\)\([ 	]*\)~/xxx\1xxx\^xxx\2xxx~\3xxx/g
#s/\^\([ 	]*\)\(.*\)\([ 	]*\)~/\1\^\2~\3/g

s/\^   /   \^/g
s/\^  /  \^/g
s/\^ / \^/g
#
#Eat white space before ~

s/\([ 	]*\)~/~\1/g

#
#
#s/   ~/~   /g
#s/  ~/~  /g
#s/ ~/~ /g
#
#
# Get rid of the subscript problem on r and v only Landino

s/\+r\~/r/g
s/\+v\~/v/g


