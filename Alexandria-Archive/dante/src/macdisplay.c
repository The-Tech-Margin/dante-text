/*	$Header: display.c,v 1.6 86/09/30 14:22:40 dante Exp $
 *
 *	DISPLAY.C - convert "standard" Dante escapes into character sequences
 *		    that are displayable on micros or terminals
 *
 *	Usage
 *		DISPLAY  [-p] [-c] [-f]	[ <infile>  [ <outfile> ] ]
 *
 *		File names default to stdin and stdout respectively.  If
 *		<infile> is "-", stdin is used.
 *
 *		The -p flag causes non-representable characters to be
 *		preserved in escape form.  Otherwise they are shown plain.
 *
 *		The -c and -f flags SURPRESS conversion of special
 *		characters and of font codes, repsectively.
 */


/*
 *	Exactly one of the following defines should be used to select
 *	the particular micro or terminal.
 */

#define MACINTOSH		/* UNIX preparation of Mac-readable files */
/* #define RAINBOW		/* DEC Rainbow microcomputer */
/* #define IBMPC		/* IBM Personal Computer + ANSI.SYS driver */
/* #define UNIX200		/* VT200 (VT100 mode) as Unix terminal */

/*
 *	Specific characteristics implied by the primary display types
 */

#ifdef	RAINBOW
#define	VT200
#define	DISPLAY
#define ANSI
#define TABLES
#endif

#ifdef	IBMPC
#define	ANSI
#define TABLES
#endif

#ifdef	MACINTOSH
#define TABLES
#define ANSI
#define DISPLAY
#define UNIX
#endif

#ifdef	UNIX200
#define VT200
#define DISPLAY
#define ANSI
#define TABLES
#define UNIX
#endif


#include <stdio.h>
#include "display.h"

#ifdef	UNIX
#include <sys/ioctl.h>
#include <signal.h>
#include <fcntl.h>
#define strchr	index
int cleanup();
int localmode;
int filedes;
#endif

#ifdef DISPLAY
#define	SET_VT200_MODE	"\033[62\"p"
#define	SET_VT100_MODE	"\033[61\"p"
#endif

FILE *in, *out;

main(argc,argv)
	int argc;
	char *argv[];
{
	char buf[MAXLINE], *display();
	int pflag = 0;
	int cflag = 1, fflag = 1;

	while (--argc > 0 && **++argv == '-' && *((*argv)+1)) {
		switch (*(++*argv)) {
			case 'p':
				pflag++;
				break;
			case 'c':
				cflag = 0;
				break;
			case 'f':
				fflag = 0;
				break;
			default:
				fprintf(stderr,"display: bad arg: %s\n", *argv);
				exit (1);
		}
	}

	switch (argc) {
	case 0:
		in = stdin;
		out = stdout;
		break;
	case 1:
		out = stdout;
		goto openin;
	case 2:
		if ((out = fopen(argv[1],"a")) == NULL) {
			fprintf(stderr,"Cannot open %s\n", argv[1]);
			exit (1);
		}
openin:
		if (!strcmp(argv[0],"-")) {
			in = stdin;
		} else if ((in = fopen(argv[0],"r")) == NULL) {
			fprintf(stderr,"Cannot open %s\n", argv[0]);
			exit (1);
		}
	}

#ifdef	UNIX
	/*
	 * If we are sending output from Unix to a tty, then go into
	 * LITOUT mode so we have an 8-bit datapath.  
	 */
	if (isatty(filedes = fileno(out))) {
		if (ioctl(filedes,TIOCLGET,&localmode) == -1) {
			perror("display: ioctl TIOCLGET");
			exit(1);
		}
		localmode |= LLITOUT;
		if (ioctl(filedes,TIOCLSET,&localmode) == -1) {
			perror("display: ioctl TIOCLSET");
			exit(1);
		}
		if (signal(SIGINT,SIG_IGN) != SIG_IGN)
			signal(SIGINT,cleanup);
	}
#ifdef DISPLAY
	fputs(SET_VT200_MODE, out);
#endif
#endif

	while (fgets(buf,MAXLINE,in)) {
		fputs(display(buf,pflag,cflag,fflag), out);
#ifdef	UNIX
		fputc('\r',out);	/* needed 'cuz of RAW mode */
#endif
	}

	cleanup();
}


cleanup()
{
#ifdef UNIX
#ifdef DISPLAY
	fputs(SET_VT100_MODE, out);
#endif
	fflush(out);
	localmode &= ~LLITOUT;
	(void)ioctl(filedes,TIOCLSET,&localmode);
#endif
	fclose(out);
	exit(0);
}

/*
 *	display - convert standard Dante into displayable sequences.
 *		If the preserve flag is set, keep the escape sequence for
 *		characters that cannot be represented.	Otherwise, use
 *		a best guess at a representation, probably the plain 
 *		character.  The cflag and fflag control conversion of
 *		characters and fonts.
 *
 *		Out-of-sequence font change codes - essentially codes
 *		saying "go to foo" when we are already using foo -
 *		are passed through unchanged to output.
 *
 *		This version does NOT implement Greek characters.  The
 *		Rainbow doesn't display them anyway.
 */


char *display(s,preserve,dochars,dofonts)
	char *s;
	int preserve,dochars,dofonts;
{
	char buf[MAXLINE], *b, c, *p, *advcpy(), *strchr();
	int diacritic;
	static int doing_bold = 0, doing_italic = 0;

	b = buf;
	do {
		switch (*s) {

		case STDBOLD:
			if (!doing_bold && dofonts) {
				b = advcpy(b, DISPLAYBOLD);
				doing_bold++;
			} else {
				*b++ = *s;
			}
			break;

		case STDITALIC:
			if (!doing_italic && dofonts) {
				b = advcpy(b, DISPLAYITALIC);
				doing_italic++;
			} else {
				*b++ = *s;
			}
			break;

		case STDNORMAL:
			if (doing_bold || doing_italic) {
				b = advcpy(b, DISPLAYNORMAL);
				doing_bold = doing_italic = 0;
			} else {
				*b++ = *s;
			}
			break;

#ifndef MACINTOSH
		case STDDEGREE:
			if (dochars && DISPLAYDEGREE)
				*b++ = DISPLAYDEGREE;
			else
				*b++ = STDDEGREE;
			break;
#endif

		case STDLQUOTE:
			if (dochars && DISPLAYLQUOTE)
				*b++ = DISPLAYLQUOTE;
			else
				*b++ = STDLQUOTE;
			break;

		case STDRQUOTE:
			if (dochars && DISPLAYRQUOTE)
				*b++ = DISPLAYRQUOTE;
			else
				*b++ = STDRQUOTE;
			break;

		case STDGRAVE:
			diacritic = GRAVE;
			goto dodi;

		case STDACUTE:
			diacritic = ACUTE;
			goto dodi;

		case STDCARET:
			diacritic = CARET;
			goto dodi;

		case STDUMLAUT:
			diacritic = UMLAUT;
dodi:
			if (dochars) {
				if ((p = strchr(plain, *(s+1))) != NULL) {
					s++;
					if (c = foreign[p-plain][diacritic])
						*b++ = c;
					else {
						if (preserve)
							*b++ = *(s-1);
						*b++ = *s;
					}
				} else if (diacritic == GRAVE && *(s+1) == STDGRAVE) {
					switch (*(s+2)) {
						case 'A':
							*b++ = LIGAE;
							goto endlig;
						case 'a':
							*b++ = LIGae;
							goto endlig;
						case 'O':
							*b++ = LIGOE;
							goto endlig;
						case 'o':
							*b++ = LIGoe;
						endlig:
							s += 3;
							break;
						default:
							*b++ = *s;
					}
				} else {
					*b++ = *s;
				}
			} else {	/* escape for unknown char */
				*b++ = *s;
			}
			break;

		default:
			*b++ = *s;
		}
	} while (*s++);

	return buf;
}





/*
 *	advcpy - like strcpy except return pointer to ending NULL of target
 */

static char *advcpy(t,s)
	register char *t, *s;
{
	do  {
		*(t++) = *s;
	} while (*(s++));
	return (t-1);
}
