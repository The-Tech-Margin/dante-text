abbr:	lex.yy.c
	cc -O -o abbr lex.yy.c -ll

lex.yy.c:	abbr.l
	lex abbr.l

install:	abbr
	install -s abbr /dante/bin/abbr
