/*
 *	main.c  Main routine of the todec filter
 *
 *	Usage
 *		todec  [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 */


#include <stdio.h>

extern	char *lexinp, *lexoutp;

main(argc,argv)
	int argc;
	char *argv[];
{
	FILE	*in, *out;
	char	inbuf[BUFSIZ], outbuf[BUFSIZ];

	out = stdout;
	in = stdin;
	switch (argc) {
	case 1:
		break;
	case 3:
		if ((out = fopen(argv[2],"a")) == NULL) {
			fprintf(stderr,"%s: cannot open %s\n",
				argv[0], argv[2]);
			exit (1);
		}
	case 2:
		if (!strcmp(argv[1],"-")) {
			in = stdin;
		} else if ((in = fopen(argv[1],"r")) == NULL) {
			fprintf(stderr,"%s: cannot open %s\n",
				argv[0], argv[1]);
			exit (1);
		}
		break;
	default:
		fprintf(stderr,"Usage: %s  [infile [outfile]]\n", argv[0]);
		exit(1);
	}
	while (fgets(inbuf, sizeof inbuf, in) != NULL) {
		lexinp = inbuf;
		lexoutp = outbuf;
		yylex();
		fputs(outbuf, out);
	}
	exit(0);
}
