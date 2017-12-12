set	path=( $HOME/bin /1g/BRS/Bin /usr/bin /usr/local/bin /usr/bin/X11 /usr/afsws/bin . )
umask	002
set	history=2000
set	mail=/usr/spool/mail/dante
set	notify
set	cdpath=$home
set	jw=/afs/northstar/ufac/jwallace/private/Dante/data
setenv	Dante	/people/dante
setenv	Brs	/1g/BRS
setenv	BRSConfig	/usr/lib/brssearch
#setenv	TEXINPUTS	".:$home/lib:/usr/lib/tex/macros"
setenv	LESS '-BemP?f%f :stdin .?m(file %i of %m) .?pb%pb\% :?bb%bb chars..$'
setenv	EDITOR	/usr/bin/vi
alias	sedf	'sed -f $home/lib/\!:^.sed \!\!:2*'
alias	iam	'source $home/.\!$rc'
alias	mail	source $home/.fixmail
alias	term	'setenv TERM `tset - -I -Q \!$`'
alias	pgrep	'ps ax | grep'
alias	checkhead	'head -3 *.e | more'
alias	so	source ~/.cshrc
alias	vic	vi ~/.cshrc
alias	xt	xterm -sb -sl 1000 -title dante -name dante
alias	dis	setenv DISPLAY poohsticks:0
alias 	hoth2	setenv DISPLAY hoth:2
alias   klog    /usr/vice/etc/klog
setenv	VVTERM	vt220
setenv	VVTERMCAP	/1g/BRS/Config/Terminals/vvtermcap
set	LoadOrder=~/C.ng/LoadOrder
set	comms=(andreoli barbi bennassuti benvenuto berthier bianchi boccaccio bosco buti campi carroll cassinALL cassinese1 cassinese2 castel chimenz costa daniello dellungo disiena fallani fiorentino giacalone grabher grandgent graziolo guido guiniforto jacopo lana landino lombardi lombardus longfellow mattalia mestica momigliano oelsner ottimo padoan pasquini pietro pietro2 pietrobono poem poletto porena portirelli provenzal rossetti ruskin sapegno scartazzini selmiano serravalle singleton steiner tommaseo torraca tozer trucchi vandelli vellutello venturi)
