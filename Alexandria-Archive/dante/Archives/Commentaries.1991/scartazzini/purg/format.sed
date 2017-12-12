s/^|Inferno canto/|INFERNO CANTO/
s/^|Purgatorio canto/|PURGATORIO CANTO/
s/^|Paradiso canto/|PARADISO CANTO/
/^$/N
s/\n     [^ ]/\
.I\
     /g
s/\n\([^ 	\.]\)/\
.U\
\1/g
s/\n	/\
.P\
/g
