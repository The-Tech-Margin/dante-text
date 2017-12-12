/*	dehyphen.c - remove hyphenated words
 *
 *	Usage
 *		dehyphen  [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 */


#include <stdio.h>

#define	COPY	0
#define HYLAST	1
#define NEEDNL	2

main(argc,argv)
	int argc;
	char *argv[];
{
	char *pgmname = argv[0];
	char errmsg[100];
	int state = COPY;
	char c;

	switch (argc) {
	case 1:				/* no file names */
		break;
	case 2:				/* inputfile only */
		goto openin;
	case 3:
		if (freopen(argv[2],"a",stdout) == NULL) {
			sprintf(errmsg,"%s: %s", pgmname, argv[2]);
			perror(errmsg);
			exit (1);
		}
openin:
		if (strcmp(argv[1],"-")) {
			if (freopen(argv[1],"r",stdin) == NULL) {
				sprintf(errmsg,"%s: %s", pgmname, argv[1]);
				perror(errmsg);
				exit (1);
			}
		}
	}

	while ((c = getchar()) != EOF) {
		switch (c) {

		case '-':
			if (state == HYLAST)
				putchar('-');
			else
				state = HYLAST;
			break;

		case '\n':
			if (state == HYLAST)
				state = NEEDNL;
			else {
				state = COPY;
				putchar(c);
			}
			break;

		default:
			if (state == HYLAST) {
				putchar('-');
				state = COPY;
			}
			putchar(c);
			break;

		case ' ':
			if (state == NEEDNL) {
				putchar('\n');
				state = COPY;
			} else if (state == HYLAST) {
				putchar('-');
				state = COPY;
				putchar(c);
			} else
				putchar(c);
			break;
		}
	}
}
