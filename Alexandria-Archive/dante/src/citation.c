/*
 *	Scan input, producing a citation list on output.
 *
 *	Usage
 *		citation  -C cantica -c canto  [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 */


#include <stdio.h>
#include <ctype.h>
#include "display.h"

#define STARTCIT	'['
#define ENDCIT		']'

main(argc,argv)
	int argc;
	char *argv[];
{
	char *pgmname = argv[0];
	char errmsg[100];
	char *cantica, *canto;
	char linebuf[50], *linep;
	char citbuf[100], *citp;
	int c;

	while (--argc > 0 && **++argv == '-') {
		switch (*(++*argv)) {
			case 'c':
				canto = *++argv;
				argc--;
				break;
			case 'C':
				cantica = *++argv;
				argc--;
				break;
			default:
				fprintf(stderr,"%s: bad arg: %s\n",pgmname,*argv);
				exit (1);
		}
	}

	switch (argc) {
	case 0:				/* no file names */
		break;
	case 1:				/* inputfile only */
		goto openin;
	case 2:
		if (freopen(argv[1],"a",stdout) == NULL) {
			sprintf(errmsg,"%s: %s", pgmname, argv[1]);
			perror(errmsg);
			exit (1);
		}
openin:
		if (strcmp(argv[0],"-")) {
			if (freopen(argv[0],"r",stdin) == NULL) {
				sprintf(errmsg,"%s: %s", pgmname, argv[0]);
				perror(errmsg);
				exit (1);
			}
		}
	}

	if (cantica == NULL || canto == NULL) {
		fputs("Usage: citation -C cantica -c canto [{infile | -} outfile]\n", stderr);
		exit(1);
	}

	while ((c = getchar()) != EOF) {
		if (c == '\t') {
			if ((c = getchar()) == STDBOLD) {
				linep = linebuf;
				while (isalnum(c = getchar()))
					*linep++ = c;
				*linep = '\0';
			}
		}

		else if (c == STARTCIT) {
			citp = citbuf;
			while ((c = getchar()) != ENDCIT) {
				if (c == EOF)
					break;
				if (c == '\n')
					*citp++ = ' ';
				else
					*citp++ = c;
			}
			*citp = '\0';
			printf("%s <.> %s.%s.%s\n",
				citbuf, cantica, canto, linebuf);
		}
	}
}
