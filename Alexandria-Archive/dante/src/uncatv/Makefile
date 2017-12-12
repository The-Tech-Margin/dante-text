uncatv:	uncatv.l
	lex uncatv.l
	cc -O  -o uncatv lex.yy.c -ll
	rm lex.yy.c

install: uncatv
	install -s uncatv ../../bin
