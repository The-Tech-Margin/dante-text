s/\#0\#, TRUCCHI PURGATORIO PVR CANTO \([0-9][0-9]*\)//g
s/\#0\#, TRUCCHI PURGATORIO PVR \([0-9][0-9]*\)//g
s/\#0\#,TRUCCHI PURGATORIO PVR CANTO \([0-9][0-9]*\)//g
s/\#0\#,TRUCCHI PURGATORIO PVR \([0-9][0-9]*\)//g

s/\#0\#,//g

s/\\T/	/g
s/\([0-9]\) -- \([0-9]\)/\1-\2/g
s/\([0-9]\) - \([0-9]\)/\1-\2/g

s/^	\([0-9][0-9]*\.\)/	|\1\~/g
s/^	\([0-9][0-9]*-[0-9][0-9]*\.\)/	|\1\~/g

s/^	/.P\
/
