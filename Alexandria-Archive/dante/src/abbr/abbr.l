%%
[a-z]+\.	{
		yytext[yyleng-1] = '\0';
		printf("%s\n", yytext);
		}

\n	|
.		;
