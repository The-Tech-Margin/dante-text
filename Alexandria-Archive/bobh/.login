setenv  Brs             /1g/BRS
setenv  BRSConfig       /usr/lib/brssearch
setenv  Dante           ~dante

set     term=`tset - -I -Q -m vt52:\?vt200 -m network:\?vt200 $term`
set     path=( $home /usr/local/bin /bin /usr/bin $Brs/Bin . )
set     history=20
set     mail=/usr/spool/mail/bobh
setenv  EDITOR  /usr/bin/vi
alias   brslock $Brs/Bin/brslock
alias	note	$Dante/bin/note
