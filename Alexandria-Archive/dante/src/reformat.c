/*	reformat.c - intuit formatting of a ddp file and put in
 *		appropriate nroff macros
 *
 *	Usage
 *		reformat  [ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 *	Written by Jonathan Altman, using STC's file-opening code
 */


#include <stdio.h>

#define	MAXLINE 512
#define	BLANK ""
#define	TAB '\t'
#define SPACE ' '
#define	IS_TAB -124
#define PARA ".P"
#define	UNDENT	".U"
#define	EXDENT	".X"
#define INDENT	".I"
#define	INTEXT	".T"

char line[MAXLINE];
char firstline[MAXLINE];
char secondline[MAXLINE];

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

	gets(line);
	if (line[0] != SPACE || line[0] != TAB || (strcmp(BLANK, line)) != 0) {
		puts(UNDENT);
		puts(line);
	}
	while (gets(line)) {
		puts(line);
		if ( strcmp(BLANK, line) == 0)
			doformat();
	}
}

/*
 *	doformat - figures out which type of paragraph we have,
 *		and puts in appropriate macro, plus the lines in buffer	
 *	
 */

doformat() {
	gets(firstline);
	if (firstline[0] == TAB ) {
		puts(PARA);
		puts(firstline);
	}
	else if (firstline[0] == SPACE) {
		gets(secondline);
		if ( strcmp(BLANK, secondline) == 0){
			puts(INDENT);
			puts(firstline);
			puts(secondline);
			doformat();
			return;
		}
		else if ( strlen(firstline) >= 55 || strlen(secondline) >= 55) {
			puts(INTEXT);
			puts(firstline);
			puts(secondline);
			return;
		}
		else {
			puts(INDENT);
			puts(firstline);
			puts(secondline);
			return;
		}
	}
	else {
		gets(secondline);
		if ( strcmp(BLANK, secondline) == 0){
			puts(UNDENT);
			puts(firstline);
			puts(secondline);
			doformat();
			return;
		}
		if (secondline[0] == SPACE ) {
			puts(EXDENT);
			puts(firstline);
			puts(secondline);
			return;
		}
		else {
			puts(UNDENT);
			puts(firstline);
			puts(secondline);
			return;
		}
	}
}
