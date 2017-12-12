/*	detilde.c - remove extraneous (non-font ending) tildes 
 *
 *	Usage
 *		detilde  [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 *	Written by Jonathan Altman by modifying STC's dehyphen utility
 */


#include <stdio.h>

#define	FONT_OFF	0
#define	FONT_ON	1
#define	TILDE	'~'
#define BAR	'|'
#define CARET	'^'
#define SUPER	'+'

main(argc,argv)
	int argc;
	char *argv[];
{
	char *pgmname = argv[0];
	char errmsg[100];
	int state = FONT_OFF;
	int tootildes = 0;
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

		case BAR:
		case CARET:
		case SUPER:
			if (state == FONT_OFF) {
				state = FONT_ON;
				putchar(c);
			}
			else putchar(c);
			break;

		case TILDE:
			if (state == FONT_ON) {
				putchar(c);
				state = FONT_OFF;
			}
			else {
				++tootildes;
			}
			break;
		default:
			putchar(c);
			break;

		}
	}
fprintf(stderr,"Warning: %d tildes removed\n", tootildes);
}
