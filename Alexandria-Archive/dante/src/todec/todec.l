VOWEL		[AaEeIiOoUu]
%{
char	*lexinp, *lexoutp;
static	char *lexworkp;
#undef	getc
#undef	output
#undef	ECHO
#define	output(c)	(*lexoutp++=(c))
#define	getc()	(*lexinp++)
#define	outs(s)	{for(lexworkp=s; *lexworkp; *lexoutp++ = *lexworkp++);}
#define	ECHO	outs(yytext)
#define	yywrap()	(*lexoutp = '\0',1)
%}
%%
"|"		outs("\033[1m");	/* bold */
"^"		outs("\033[4m");	/* underscored (italic) */
\+[^~]+~	output('\260');		/* degree mark */
~		outs("\033[0m");	/* normal rendition */
"<<<"|">>>"	ECHO;
"<"		output('\253');
">"		output('\273');
@@ae		output('\346');
@@A[eE]		output('\306');
@@oe		output('\367');
@@O[eE]		output('\327');
@({VOWEL}|[Qq])	{
		switch (yytext[1]) {		/* accent grave */
			case 'A':	output('\300'); break;
			case 'a':	output('\340'); break;
			case 'E':	output('\310'); break;
			case 'e':	output('\350'); break;
			case 'I':	output('\314'); break;
			case 'i':	output('\354'); break;
			case 'O':	output('\322'); break;
			case 'o':	output('\362'); break;
			case 'U':	output('\331'); break;
			case 'u':	output('\371'); break;
			case 'Q':	output('\121'); break;
			case 'q':	output('\161'); break;
		};
		}

\$({VOWEL}|[QqCc]) {
		switch (yytext[1]) {		/* accent acute */
			case 'A':	output('\301'); break;
			case 'a':	output('\341'); break;
			case 'E':	output('\311'); break;
			case 'e':	output('\351'); break;
			case 'I':	output('\315'); break;
			case 'i':	output('\355'); break;
			case 'O':	output('\323'); break;
			case 'o':	output('\363'); break;
			case 'U':	output('\332'); break;
			case 'u':	output('\372'); break;
			case 'Q':	output('\121'); break;
			case 'q':	output('\161'); break;
			case 'C':	output('\307'); break;
			case 'c':	output('\347'); break;
		};
		}

\,{VOWEL}	{
		switch (yytext[1]) {		/* umlaut */
			case 'A':	output('\304'); break;
			case 'a':	output('\344'); break;
			case 'E':	output('\313'); break;
			case 'e':	output('\353'); break;
			case 'I':	output('\317'); break;
			case 'i':	output('\357'); break;
			case 'O':	output('\326'); break;
			case 'o':	output('\366'); break;
			case 'U':	output('\334'); break;
			case 'u':	output('\374'); break;
		};
		}

#{VOWEL}	{
		switch (yytext[1]) {		/* caret */
			case 'A':	output('\302'); break;
			case 'a':	output('\342'); break;
			case 'E':	output('\312'); break;
			case 'e':	output('\352'); break;
			case 'I':	output('\316'); break;
			case 'i':	output('\356'); break;
			case 'O':	output('\324'); break;
			case 'o':	output('\364'); break;
			case 'U':	output('\333'); break;
			case 'u':	output('\373'); break;
		};
		}
