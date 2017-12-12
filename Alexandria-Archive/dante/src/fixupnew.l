%%
		char *p;
[IVXLCDM]+	ECHO;
[A-Z][A-Z ]+	{
		*p = '|';
/* setting p = 'a' and p = '#' also crash, so | isn't confusing lex */
		for (p = yytext+1; *p; p++) {
			if (*p != ' ')
				*p += ('a'-'A');
		}
		*p += '~';
		printf("%s",yytext);
		}
