%{
#define DIACRIT(a)	((a) == '@' ? '`' : ((a) == ',' ? '"' : '$'))
%}
%%
"|"		printf("\\bf");
"^"		printf("\\sl");
"+"		printf("$^\\circ$");
~" "		printf("\\rm\\ ");
~$		printf("\\rm");
~		printf("\\rm ");
"<"		printf("\\<");
">"		printf("\\>");
@@ae		printf("\\ae ");
@@ae" "		printf("\\ae\\ ");
@@A[eE]		printf("\\AE ");
@@A[eE]" "	printf("\\AE\\ ");
@@oe		printf("\\oe ");
@@oe" "		printf("\\oe\\ ");
@@O[eE]		printf("\\OE ");
@@O[eE]" "	printf("\\OE\\ ");
[@,$]i		printf("\\%c\\i ", DIACRIT(yytext[0]));
[@,$]i" "	printf("\\%c\\i\\ ", DIACRIT(yytext[0]));
[@,$][A-Za-z]	printf("\\%c%c", DIACRIT(yytext[0]), yytext[1]);
