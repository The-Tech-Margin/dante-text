/*	typefix.c - fix up macintosh-typed files where typists
 *		have left paragraphs without returns at ends of
 *		each line
 *
 *	Usage
 *		typefix [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is -, stdin is used.
 *
 *	Written by Jonathan Altman, using STCs file-opening code
 */

#include <stdio.h>

#define TAB '\011'
#define RETURN '\012'
#define SPACE ' '

int c,i;

main(argc,argv)
	int argc;
	char *argv[];
{
	char *pgmname = argv[0];
	char errmsg[100];

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

	while ((c=getchar()) != EOF) {
		if (c == TAB) {
			putchar(RETURN);
			i=0;
		}
		if ((i++) >= 60 && c == SPACE) {
			i=0;
			c=RETURN;
		}
		putchar(c);
	}
}

