/*
 *	dbloadf - Filter for just before database loading
 *
 *	Usage
 *		dbloadf  <flags>  [ <infile>  [ <outfile> ] ]
 *
 *		flags:
 *			-c<commentary>
 *			-l<language>
 *			-p<publication year>
 *			-t<DTYP value>	[optional]
 *			-a<cantica>	[optional]
 *			-o<canto>	[optional]
 *			-r		[copyrighted]
 *			-d		[debug]
 *
 *	File names default to stdin and stdout respectively.  If
 *	<infile> is "-", stdin is used.
 *
 */


#include <stdio.h>
#include <ctype.h>

#define	MAXLINE		512

#define FMTOFF		"<<<FORMATTING-OFF>>>"
#define FMTON		"<<<FORMATTING-ON>>>"

/*
 *	Line types, as returned by linetype()
 */
#define LINENOS		0
#define BLANK		1
#define TAB		2
#define INDENTED	3
#define NOBLANK		4
#define PROEMIO		5
#define DOC_BREAK	6
#define NOTA		7

char *pgmname;
char *comm = NULL, *lang = NULL, *pubdate = NULL,
     *dtyp = NULL, *cantica = NULL, *canto = NULL;
int start_line, end_line;
char line[MAXLINE];
char *textptr;
char errmsg[MAXLINE];
int nblines, inlines;
int copyrighted = 0;

main(argc,argv)
	int argc;
	char *argv[];
{
	register int fmt_is_on, need_blank, lt;
	long textchars;
	int debug = 0;

	pgmname = argv[0];
	while (--argc > 0 && **++argv == '-' && *(*argv + 1)) {
		switch (*(*argv + 1)) {
			case 'c':
				comm = *argv + 2;
				break;
			case 'l':
				lang = *argv + 2;
				break;
			case 'p':
				pubdate = *argv + 2;
				break;
			case 't':
				dtyp = *argv + 2;
				break;
			case 'a':
				cantica = *argv + 2;
				break;
			case 'o':
				canto = *argv + 2;
				break;
			case 'r':
				copyrighted++;
				break;
			case 'd':
				debug++;
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
			sprintf(errmsg,"%s: %s", pgmname, argv[1]);
			perror(errmsg);
			exit (1);
		}
openin:
		if (strcmp(argv[0],"-")) {
			if (freopen(argv[0],"r",stdin) == NULL) {
				sprintf(errmsg,"%s: %s", pgmname, argv[0]);
				perror(errmsg);
				exit (1);
			}
		}
	}

	if (debug) {
		fprintf(stderr,"\tCOMM: %s\n\tLANG: %s\n\tPUBD: %s\n\tDTYP: %s\n\tCTCA: %s\n\tCNTO: %s\n",
			comm, lang, pubdate, dtyp, cantica, canto);
	}

	fmt_is_on = 1;
	need_blank = 0;
	textchars = 0;
	while (gets(line)) {
		inlines++;
		lt = linetype();
		if (nblines == 0 && lt == BLANK)
			continue;
		if (++nblines == 1 ||
		    lt == LINENOS || lt == PROEMIO || lt == DOC_BREAK ||
		    lt == NOTA) {
			if (textchars) {
				printf("..TCHR: %ld\n", textchars);
				textchars = 0;
			}
			printf("..COMM: %s\n", comm);
			printf("..LANG: %s\n", lang);
			printf("..PUBD: %s\n", pubdate);
			if (copyrighted)
				printf("..ATTR: copyright\n");
			printf("..LODD:\n");
			switch (lt) {
			case PROEMIO:
				printf("..DTYP: %s\n", "I");
				break;
			case NOTA:
				printf("..DTYP: %s\n", "N");
				break;
			default: 
				printf("..DTYP: %s\n", dtyp);
				break;
			}
			if (cantica && *cantica)
				printf("..CTCA: %s\n", cantica);
			if (canto && *canto)
				printf("..CNTO: %s\n", canto);
			if (start_line > 0)
				printf("..LINE: %d\n", start_line);
			if (end_line > 0) 
				printf("..ENDL: %d\n", end_line);
			printf("..TEXT:\n");
			fmt_is_on = 1;
			need_blank = 0;
		}
		switch (lt) {
			case BLANK:
				need_blank = 1;
				fmt_is_on = 1;
				break;

			case TAB:
			case LINENOS:
			case PROEMIO:
			case NOTA:
			case DOC_BREAK:
				if (need_blank) {
					fputc('\n', stdout);
					need_blank = 0;
				}
				if (fmt_is_on == 0) {
					puts(FMTON);
					fmt_is_on = 1;
				}
				puts(textptr);
				textchars += strlen(textptr);
				break;

			case INDENTED:
				if (need_blank) {
					fputc('\n', stdout);
					need_blank = 0;
				}
				if (fmt_is_on) {
					puts(FMTOFF);
					fmt_is_on = 0;
				}
				puts(line);
				textchars += strlen(line);
				break;

			case NOBLANK:
				if (need_blank) {
					fputc('\n', stdout);
					need_blank = 0;
				}
				if (fmt_is_on == 0) {
					puts(FMTON);
					fmt_is_on = 1;
				}
				puts(line);
				textchars += strlen(line);
				break;

			default:
				sprintf(errmsg,"near line %d: bad linetype\n", inlines);
				fputs(errmsg,stderr);
				break;
		}
	}
}


/*
 *	linetype - figure out what kind of input line we have
 *
 *	side effects: sets start_line, end_line, and textptr
 */
linetype()
{
	register int col, scancount, tilde;
	int retval;

	start_line = end_line = 0;
	col = 1;
	for (textptr = line; textptr && isspace(*textptr); textptr++) {
		if (*textptr == '\t')
			col = (((col + 7) / 8) * 8) + 1;
		else
			col++;
	}

	if (*textptr == '\0')
		return(BLANK);
	if (col == 1) {
		if (strcmp(textptr,"DOC_BREAK") == 0 ||
		    strcmp(textptr,"DOC-BREAK") == 0) {
			retval = DOC_BREAK;
			goto adjust;
		} else
			return(NOBLANK);
	}
	if (col != 9)
		return(INDENTED);
	if (*textptr != '|')
		return(TAB);
	
	/*
	 *  Assumed format is |%d-%d with the second number defaulting to 0,
	 *  or |Proemio.
	 */
	scancount = sscanf(++textptr, "%d-%d", &start_line, &end_line);
	if (scancount >= 1)
		retval = LINENOS;
	else if (strncmp(textptr, "Proemio", strlen("Proemio")) == 0)
		retval = PROEMIO;
	else if (strncmp(textptr, "Nota", strlen("Nota")) == 0)
		retval = NOTA;
	else {
#ifdef notdef
		sprintf(errmsg,"line %d: warning: boldface at column 9:\n%s\n",
			inlines, line);
		fputs(errmsg,stderr);
#endif
		textptr--;
		return(TAB);
	}

	/*
	 * Move to the start of text. Note if a ~ (font reset) occurs.
	 * If it does not, then we must insert a | in front of the
	 * remaining text to maintain the original font.  For example:
	 *	"|3-4  foobar" -> "|foobar"
	 */
adjust:
	tilde = 0;
	while (!isspace(*++textptr))
		if (*textptr == '~')
			tilde++;
	while (isspace(*++textptr)) ;
	if (tilde == 0)
		*(--textptr) = '|';
	return(retval);
}
