/*	marksect.c - protect the formatting of indented sections in
 *		ddp files and add RTF paragraph marks at the end of
 *		each macro-separated section of text
 *
 *	Usage
 *		marksect [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is -, stdin is used.
 *
 *	Written by Jonathan Altman, using STCs file-opening code
 */

#include <stdio.h>

#define	MAXLINE 512
#define	BLANK ""
#define INDENT	".I"
#define PARA	".P"
#define UNDENT	".U"
#define INFILL	".T"
#define EXDENT	".X"
#define	LINEND	"\\par"

char line[MAXLINE];
char holdline[MAXLINE];

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

	while (gets(line)) {
		puts(line);
		if (strcmp(line, INDENT) == 0) {
			while(strcmp(gets(line, BLANK)) != 0) {
				printf("%s%s\n", line, LINEND);
			}
			puts(line);
		}
		else if (strcmp(line, PARA) == 0 || strcmp(line,EXDENT) == 0 || strcmp(line,UNDENT) == 0 || strcmp(line,INFILL) == 0) {
			while(strcmp(gets(line), BLANK) != 0){
				if ((strcmp(holdline,BLANK)) != 0)
					puts(holdline);	
				strcpy(holdline, line);
			}
			if (strcmp(line, BLANK) == 0) {
				printf("%s%s\n", holdline, LINEND);
				puts(line);
				strcpy(holdline, BLANK);
			}
		}
	}
}

