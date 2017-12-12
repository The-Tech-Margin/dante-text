/*	$Header: display.h,v 1.4 86/09/30 14:23:10 dante Exp $
 *
 *	DISPLAY.H - definitions for translating Standard to microcomputer
 */

#define MAXLINE 512

/*
 *	Escape characters in the Standard Dante set
 */

#define 	STDBOLD 	'|'
#define 	STDITALIC	'^'
#define 	STDGREEK	'_'
#define 	STDNORMAL	'~'
#define 	STDLQUOTE	'<'
#define 	STDRQUOTE	'>'
#define 	STDGRAVE	'@'
#define 	STDACUTE	'$'	/* Used for cedillas, too. */
#define		STDUMLAUT	','
#define 	STDDEGREE	'+'
#define		STDCARET	'#'

/*
 *	ANSI standard graphic representation sequences
 */

#ifdef ANSI
#define 	DISPLAYBOLD	  "\033[1m"
#define 	DISPLAYITALIC	  "\033[4m"
#define 	DISPLAYNORMAL	  "\033[0m"
#endif

/*
 *	Characters used by specific displays
 */

#ifdef IBMPC
#define 	DISPLAYLQUOTE	  '\256'
#define 	DISPLAYRQUOTE	  '\257'
#define 	DISPLAYDEGREE	  '\370'
#endif

#ifdef MACINTOSH
#define 	DISPLAYLQUOTE	  '\199'
#define 	DISPLAYRQUOTE	  '\200'
#endif

#ifdef VT200
#define 	DISPLAYLQUOTE	  '\253'
#define 	DISPLAYRQUOTE	  '\273'
#define 	DISPLAYDEGREE	  '\260'
#endif

/*
 *	Tables for translating foreign characters
 *
 *	Table "plain" are the plain English characters that follow the
 *	escape character(s) in the Standard Dante format.  They are
 *	mostly vowels.
 *
 *	Table "foreign" contains the corresponding characters in their
 *	diacritic representation.  The values in this table are machine-
 *	dependent.  The table is 2-dimensional: the first subscript is
 *	the index showing which plain character is being translated; the
 *	second subscript is the indicator of which escape was used, ie
 *	type of diacritic mark is being used.
 */

#ifdef TABLES

char plain[] = {
	'A',
	'a',
	'E',
	'e',
	'I',
	'i',
	'O',
	'o',
	'U',
	'u',
	'Q',
	'q',
	'C',
	'c',
	'\0'
};

#define 	GRAVE		0
#define 	ACUTE		1
#define 	UMLAUT		2
#define		CARET		3
#define		DIATYPES	4	/* How many types are there */

char escape[] = {STDGRAVE, STDACUTE, STDUMLAUT, STDCARET, '\0'};

char foreign[sizeof(plain)-1][DIATYPES] = {

#ifdef IBMPC

      /* GRAVE	 ACUTE	 UMLAUT   CARET */

	{'\000', '\000', '\000', '\000'},      /* A */
	{'\205', '\240', '\204', '\203'},      /* a */
	{'\000', '\220', '\000', '\000'},      /* E */
	{'\212', '\202', '\211', '\210'},      /* e */
	{'\000', '\000', '\000', '\000'},      /* I */
	{'\215', '\241', '\213', '\214'},      /* i */
	{'\000', '\000', '\000', '\000'},      /* O */
	{'\225', '\242', '\224', '\223'},      /* o */
	{'\000', '\000', '\000', '\000'},      /* U */
	{'\227', '\243', '\232', '\226'},      /* u */
	{'\000', '\000', '\000', '\000'},      /* Q */
	{'\000', '\000', '\000', '\000'},      /* q */
	{'\000', '\200', '\000', '\000'},      /* C */
	{'\000', '\207', '\000', '\000'}       /* c */
#endif

#ifdef VT200

      /* GRAVE	 ACUTE	 UMLAUT  CARET */

	{'\300', '\301', '\304', '\302'},      /* A */
	{'\340', '\341', '\344', '\342'},      /* a */
	{'\310', '\311', '\313', '\312'},      /* E */
	{'\350', '\351', '\353', '\352'},      /* e */
	{'\314', '\315', '\317', '\316'},      /* I */
	{'\354', '\355', '\357', '\356'},      /* i */
	{'\322', '\323', '\326', '\324'},      /* O */
	{'\362', '\363', '\366', '\364'},      /* o */
	{'\331', '\332', '\334', '\333'},      /* U */
	{'\371', '\372', '\374', '\373'},      /* u */
	{'\000', '\000', '\000', '\000'},      /* Q */
	{'\000', '\000', '\000', '\000'},      /* q */
	{'\000', '\307', '\000', '\000'},      /* C */
	{'\000', '\347', '\000', '\000'}       /* c */
#endif

#ifdef MACINTOSH

      /* GRAVE	 ACUTE	 UMLAUT  CARET */

	{'\203', '\231', '\128', '\229'},      /* A */
	{'\136', '\135', '\138', '\137'},      /* a */
	{'\233', '\131', '\232', '\230'},      /* E */
	{'\143', '\142', '\145', '\144'},      /* e */
	{'\237', '\234', '\236', '\235'},      /* I */
	{'\147', '\146', '\149', '\148'},      /* i */
	{'\241', '\238', '\133', '\239'},      /* O */
	{'\152', '\151', '\154', '\153'},      /* o */
	{'\244', '\242', '\134', '\243'},      /* U */
	{'\157', '\156', '\159', '\158'},      /* u */
	{'\000', '\000', '\000', '\000'},      /* Q */
	{'\000', '\000', '\000', '\000'},      /* q */
	{'\000', '\130', '\000', '\000'},      /* C */
	{'\000', '\141', '\000', '\000'}       /* c */
#endif

};


#ifdef	IBMPC
#define LIGAE '\222'
#define LIGae '\221'
#define LIGOE '\001'	/* OE not representable */
#define LIGoe '\002'	/* oe not representable */
#endif

#ifdef	VT200
#define LIGAE '\306'
#define LIGae '\346'
#define LIGOE '\327'
#define LIGoe '\367'
#endif

#ifdef	MACINTOSH
#define LIGAE '\174'
#define LIGae '\190'
#define LIGOE '\206'
#define LIGoe '\207'
#endif

#endif
