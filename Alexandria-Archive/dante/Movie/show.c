#include <stdio.h>

#define	STOPCHAR	014

main(argc,argv)
	int argc;
	char *argv[];
{
	int c;
	int junk;
	FILE *infile;

	if (argc != 2) {
		fprintf(stderr,"usage: %s filename\n", argv[0]);
		exit(1);
	}
	if ((infile = fopen(argv[1],"r")) == NULL) {
		fprintf(stderr,"%s: cannot open\n", argv[1]);
		exit(1);
	}
	while ((c = getc(infile)) != EOF) {
		if (c == STOPCHAR) {
			fflush(stdout);
			junk = getc(stdin);
		} else
			putc(c,stdout);
	}
}
