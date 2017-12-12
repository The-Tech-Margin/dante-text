%%
	register int meta = 0;
	register int escape = 0;
"M-"	{meta = 1;}

"^"	{escape = 1;}

"\n"	ECHO;

.	{
	if (escape) {
		*yytext &= 0x3f;
		escape = 0;
	}
	if (meta) {
		*yytext |= 0x80;
		meta = 0;
	}
	printf("%s",yytext);
}
