%%
		char *p;
[IVXLCDM]+	ECHO;
[A-Z][A-Z@#$ ]+	{
		for (p = yytext+1; *p; p++) {
			switch (*p){
				case '@':
				case '#':
				case '$':
				case ' ':
					break;
				default:
					*p += ('a'-'A');
			}
		}
		printf("%s",yytext);
		}
