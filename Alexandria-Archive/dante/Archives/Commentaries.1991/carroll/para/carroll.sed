s/\#0\#,CARROLL /|/g
s/\#0\#,//g
s/INFERNO INF /INFERNO /g

s/PURGTORIO PUR /PURGATORIO /g
s/PURGATORIO PUR /PURGATORIO /g
s/PURGTAROI PUR /PURGATORIO /g
s/PUT /PURGATORIO/g
s/ PUR /PURGATORIO/g

s/PARADISO PAR/PARADISO /g
s/CANTO \([0-9][0-9]*\)/CANTO \1\~/g

s/\\\$/\$/g

s/\([0-9]\) -- \([0-9]\)/\1-\2/g

s/@@\^/\^@@/g

s/\.' \([A-Za-z]\)/\.'  \1/g

s/\\T\\T/     /g
s/\\T/	/g
s/\\C//g

s/^'\([a-zA-Z]\)/`\1/g
s/ '\([a-zA-Z]\)/ `\1/g

s/^	/.P\
/g
