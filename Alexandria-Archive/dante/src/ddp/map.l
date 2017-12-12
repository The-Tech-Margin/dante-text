%{
#define	THIS_IS_MAP
#include "map.h"
/*
 * The string array mapstr[TERMINAL][SEQUENCE] contains the strings to be
 * output for each escape sequence for each terminal.
 */
static unsigned char *mapstr[2][58] = {
	/*
	 * Strings for the DEC VT200 and Rainbow
	 */
	{
#define BOLD		0
	(unsigned char *)"\033[1m",
#define ITALIC		1
	(unsigned char *)"\033[4m",
#define ROMAN		2
	(unsigned char *)"\033[0m",
#define DEGREE		3
	(unsigned char *)"\260",
#define L_EUROPE	4
	(unsigned char *)"\253",
#define R_EUROPE	5
	(unsigned char *)"\273",
#define UP_AE		6
	(unsigned char *)"\306",
#define LOW_AE		7
	(unsigned char *)"\346",
#define UP_OE		8
	(unsigned char *)"\327",
#define LOW_OE		9
	(unsigned char *)"\367",
#define UP_GR_A		10	/* UPper case GRave A */
	(unsigned char *)"\300",
#define LOW_GR_A	11
	(unsigned char *)"\340",
#define UP_GR_E		12
	(unsigned char *)"\310",
#define LOW_GR_E	13
	(unsigned char *)"\350",
#define UP_GR_I		14
	(unsigned char *)"\314",
#define LOW_GR_I	15
	(unsigned char *)"\354",
#define UP_GR_O		16
	(unsigned char *)"\322",
#define LOW_GR_O	17
	(unsigned char *)"\362",
#define UP_GR_U		18
	(unsigned char *)"\331",
#define LOW_GR_U	19
	(unsigned char *)"\371",
#define UP_GR_Q		20
	(unsigned char *)"\121",
#define LOW_GR_Q	21
	(unsigned char *)"\161",
#define UP_AC_A		22	/* UPper case ACute A */
	(unsigned char *)"\301",
#define LOW_AC_A	23
	(unsigned char *)"\341",
#define UP_AC_E		24
	(unsigned char *)"\311",
#define LOW_AC_E	25
	(unsigned char *)"\351",
#define UP_AC_I		26
	(unsigned char *)"\315",
#define LOW_AC_I	27
	(unsigned char *)"\355",
#define UP_AC_O		28
	(unsigned char *)"\323",
#define LOW_AC_O	29
	(unsigned char *)"\363",
#define UP_AC_U		30
	(unsigned char *)"\332",
#define LOW_AC_U	31
	(unsigned char *)"\372",
#define UP_AC_Q		32
	(unsigned char *)"\121",
#define LOW_AC_Q	33
	(unsigned char *)"\161",
#define UP_CEDILLA	34
	(unsigned char *)"\307",
#define LOW_CEDILLA	35
	(unsigned char *)"\347",
#define UP_UM_A		36	/* UPper case UMlauted A */
	(unsigned char *)"\304",
#define LOW_UM_A	37
	(unsigned char *)"\344",
#define UP_UM_E		38
	(unsigned char *)"\313",
#define LOW_UM_E	39
	(unsigned char *)"\353",
#define UP_UM_I		40
	(unsigned char *)"\317",
#define LOW_UM_I	41
	(unsigned char *)"\357",
#define UP_UM_O		42
	(unsigned char *)"\326",
#define LOW_UM_O	43
	(unsigned char *)"\366",
#define UP_UM_U		44
	(unsigned char *)"\334",
#define LOW_UM_U	45
	(unsigned char *)"\374",
#define UP_CAR_A	46	/* UPper case CAReted A */
	(unsigned char *)"\302",
#define LOW_CAR_A	47
	(unsigned char *)"\342",
#define UP_CAR_E	48
	(unsigned char *)"\312",
#define LOW_CAR_E	49
	(unsigned char *)"\352",
#define UP_CAR_I	50
	(unsigned char *)"\316",
#define LOW_CAR_I	51
	(unsigned char *)"\356",
#define UP_CAR_O	52
	(unsigned char *)"\324",
#define LOW_CAR_O	53
	(unsigned char *)"\364",
#define UP_CAR_U	54
	(unsigned char *)"\333",
#define LOW_CAR_U	55
	(unsigned char *)"\373",
#define TERMINIT	56
	(unsigned char *)"\033[62\"p",
#define TERMDEINIT	57
	(unsigned char *)"\033[61\"p\033[?7h",
	},
	/*
	 * Strings for the IBM PC
	 */
	{
/* BOLD */
	(unsigned char *)"\033[1m",
/* ITALIC */
	(unsigned char *)"\033[4m",
/* ROMAN */
	(unsigned char *)"\033[0m",
/* DEGREE */
	(unsigned char *)"\370",
/* L_EUROPE */
	(unsigned char *)"\256",
/* R_EUROPE */
	(unsigned char *)"\257",
/* UP_AE */
	(unsigned char *)"\222",
/* LOW_AE */
	(unsigned char *)"\221",
/* UP_OE */
	(unsigned char *)"OE",
/* LOW_OE */
	(unsigned char *)"oe",
/* UP_GR_A */
	(unsigned char *)"A",
/* LOW_GR_A */
	(unsigned char *)"\205",
/* UP_GR_E */
	(unsigned char *)"E",
/* LOW_GR_E */
	(unsigned char *)"\212",
/* UP_GR_I */
	(unsigned char *)"I",
/* LOW_GR_I */
	(unsigned char *)"\215",
/* UP_GR_O */
	(unsigned char *)"O",
/* LOW_GR_O */
	(unsigned char *)"\225",
/* UP_GR_U */
	(unsigned char *)"U",
/* LOW_GR_U */
	(unsigned char *)"\227",
/* UP_GR_Q */
	(unsigned char *)"Q",
/* LOW_GR_Q */
	(unsigned char *)"q",
/* UP_AC_A */
	(unsigned char *)"A",
/* LOW_AC_A */
	(unsigned char *)"\240",
/* UP_AC_E */
	(unsigned char *)"\220",
/* LOW_AC_E */
	(unsigned char *)"\202",
/* UP_AC_I */
	(unsigned char *)"I",
/* LOW_AC_I */
	(unsigned char *)"\241",
/* UP_AC_O */
	(unsigned char *)"O",
/* LOW_AC_O */
	(unsigned char *)"\242",
/* UP_AC_U */
	(unsigned char *)"U",
/* LOW_AC_U */
	(unsigned char *)"\243",
/* UP_AC_Q */
	(unsigned char *)"Q",
/* LOW_AC_Q */
	(unsigned char *)"q",
/* UP_CEDILLA */
	(unsigned char *)"\200",
/* LOW_CEDILLA */
	(unsigned char *)"\207",
/* UP_UM_A */
	(unsigned char *)"A",
/* LOW_UM_A */
	(unsigned char *)"\204",
/* UP_UM_E */
	(unsigned char *)"E",
/* LOW_UM_E */
	(unsigned char *)"\211",
/* UP_UM_I */
	(unsigned char *)"I",
/* LOW_UM_I */
	(unsigned char *)"\213",
/* UP_UM_O */
	(unsigned char *)"O",
/* LOW_UM_O */
	(unsigned char *)"\224",
/* UP_UM_U */
	(unsigned char *)"U",
/* LOW_UM_U */
	(unsigned char *)"\232",
/* UP_CAR_A */
	(unsigned char *)"A",
/* LOW_CAR_A */
	(unsigned char *)"\203",
/* UP_CAR_E */
	(unsigned char *)"E",
/* LOW_CAR_E */
	(unsigned char *)"\210",
/* UP_CAR_I */
	(unsigned char *)"I",
/* LOW_CAR_I */
	(unsigned char *)"\214",
/* UP_CAR_O */
	(unsigned char *)"O",
/* LOW_CAR_O */
	(unsigned char *)"\223",
/* UP_CAR_U */
	(unsigned char *)"U",
/* LOW_CAR_U */
	(unsigned char *)"\226",
/* TERMINIT */
	(unsigned char *)"",
/* TERMDEINIT */
	(unsigned char *)"",
	}
};

#define map(i)	(mapstr[termtype][i])

/*
 * Arrange for yylex to work on a single string rather than on stdin.
 * The results are put into another string rather than written to stdout.
 */
#undef	getc
#define	getc(x)	(*lexinp++)
#undef	ECHO
#define	ECHO	outs(yytext)
#undef	output
#define	output(c)	(*lexoutp++=(c))
#define	yywrap()	(*lexoutp = '\0',1)
#define	outs(s)	{if(italics_suspended) { \
			setmode(ITALIC); \
			italics_suspended = 0; \
		} \
		for(lexworkp=(mapon?(s):yytext); *lexworkp; *lexoutp++ = *lexworkp++); \
		}
#define setmode(m)	{for(lexmodep=(mapon?map(m):yytext); *lexmodep; *lexoutp++ = *lexmodep++);}

%}
VOWEL		[AaEeIiOoUu]
MAPPINGON	\002			/* STX or ^B */
MAPPINGOFF	\001			/* SOH or ^A */
%%
	register unsigned char *lexworkp, *lexmodep;
	register int mapon = 1;		/* enables mapping */
 /*
 * We go through a bit of extra work to work around a BRS bug.  If a line is italicized,
 * ie underscored, beyond the end of the line, the indentation blanks on the next line
 * are also underscored, which looks ugly.  So we keep track of this situation with
 * some state variables - italics and italics_suspended - and un-underscore those
 * leading blanks on the lines.
 */
	static int	italics = 0, italics_suspended = 0;

" "*\r		{
			outs((unsigned char *)"\r");
			if (italics) {
				/*
				 * end of an underscored line; need to turn off underscoring.
				 */
				setmode(ROMAN);
				italics_suspended++;
			}
		}
MAPPINGON	mapon = 1;
MAPPINGOFF	mapon = 0;
"|"		setmode(BOLD);
"^"		{setmode(ITALIC); italics++;}
\+[a-zA-Z]+~	outs(map(DEGREE));
~		{setmode(ROMAN); italics = 0;}
"<<<"|">>>"	ECHO;
"<"		outs(map(L_EUROPE));
">"		outs(map(R_EUROPE));
[^ ]		outs(yytext);
@@ae		outs(map(LOW_AE));
@@A[eE]		outs(map(UP_AE));
@@oe		outs(map(LOW_OE));
@@O[eE]		outs(map(UP_OE));
@({VOWEL}|[Qq])	{
		switch (yytext[1]) {		/* accent grave */
			case 'A':	outs(map(UP_GR_A)); break;
			case 'a':	outs(map(LOW_GR_A)); break;
			case 'E':	outs(map(UP_GR_E)); break;
			case 'e':	outs(map(LOW_GR_E)); break;
			case 'I':	outs(map(UP_GR_I)); break;
			case 'i':	outs(map(LOW_GR_I)); break;
			case 'O':	outs(map(UP_GR_O)); break;
			case 'o':	outs(map(LOW_GR_O)); break;
			case 'U':	outs(map(UP_GR_U)); break;
			case 'u':	outs(map(LOW_GR_U)); break;
			case 'Q':	outs(map(UP_GR_Q)); break;
			case 'q':	outs(map(LOW_GR_Q)); break;
		};
		}

\$({VOWEL}|[QqCc]) {
		switch (yytext[1]) {		/* accent acute */
			case 'A':	outs(map(UP_AC_A)); break;
			case 'a':	outs(map(LOW_AC_A)); break;
			case 'E':	outs(map(UP_AC_E)); break;
			case 'e':	outs(map(LOW_AC_E)); break;
			case 'I':	outs(map(UP_AC_I)); break;
			case 'i':	outs(map(LOW_AC_I)); break;
			case 'O':	outs(map(UP_AC_O)); break;
			case 'o':	outs(map(LOW_AC_O)); break;
			case 'U':	outs(map(UP_AC_U)); break;
			case 'u':	outs(map(LOW_AC_U)); break;
			case 'Q':	outs(map(UP_AC_Q)); break;
			case 'q':	outs(map(LOW_AC_Q)); break;
			case 'C':	outs(map(UP_CEDILLA)); break;
			case 'c':	outs(map(LOW_CEDILLA)); break;
		};
		}

\,{VOWEL}	{
		switch (yytext[1]) {		/* umlaut */
			case 'A':	outs(map(UP_UM_A)); break;
			case 'a':	outs(map(LOW_UM_A)); break;
			case 'E':	outs(map(UP_UM_E)); break;
			case 'e':	outs(map(LOW_UM_E)); break;
			case 'I':	outs(map(UP_UM_I)); break;
			case 'i':	outs(map(LOW_UM_I)); break;
			case 'O':	outs(map(UP_UM_O)); break;
			case 'o':	outs(map(LOW_UM_O)); break;
			case 'U':	outs(map(UP_UM_U)); break;
			case 'u':	outs(map(LOW_UM_U)); break;
		};
		}

#{VOWEL}	{
		switch (yytext[1]) {		/* caret */
			case 'A':	outs(map(UP_CAR_A)); break;
			case 'a':	outs(map(LOW_CAR_A)); break;
			case 'E':	outs(map(UP_CAR_E)); break;
			case 'e':	outs(map(LOW_CAR_E)); break;
			case 'I':	outs(map(UP_CAR_I)); break;
			case 'i':	outs(map(LOW_CAR_I)); break;
			case 'O':	outs(map(UP_CAR_O)); break;
			case 'o':	outs(map(LOW_CAR_O)); break;
			case 'U':	outs(map(UP_CAR_U)); break;
			case 'u':	outs(map(LOW_CAR_U)); break;
		};
		}
%%
unsigned char *
terminit()
{
	if (termtype == MAP_NOMAP) 
		return((unsigned char *)"ERROR: no terminal type set");
	return(map(TERMINIT));
}

unsigned char *
termdeinit()
{
	return(map(TERMDEINIT));
}
