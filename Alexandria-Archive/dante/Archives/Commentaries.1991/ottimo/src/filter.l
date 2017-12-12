%{
#include <ctype.h>
%}
%%
	int upper = 0;

^0" "?			printf("\n");
^1" "?			;
%[89]%" "?		;
\$[0-9]+\$" "?		;
^#[0-9IVXCDJ]+@		{
			printf("\n");
			yytext[yyleng-1] = '\0';
			printf(" %s",yytext+1);
			}
#[0-9IVXCDJ]+@		{
			yytext[yyleng-1] = '\0';
			printf(" %s",yytext+1);
			}
\*			upper = 1;
[A-Z][&+4]?		{
			if (yyleng == 2) {
				switch (yytext[1]) {
				case '&':
					printf("@");
					break;
				case '+':
					printf("$");
					break;
				case '4':
					printf(",");
					break;
				}
			}
			if (upper) {
				printf("%c",yytext[0]);
				upper = 0;
			}
			else
				printf("%c",tolower(yytext[0]));
			}
1			printf("`");
2			printf("'");
3			printf(">");
7			printf("-");
_			printf("\n--");
8			printf(".");
\"			printf("<");
%[>KBMD]%		{
			switch (yytext[1]) {
			case '>':
				printf("~");
				break;
			case 'K':
			case 'B':
				printf("]");
				break;
			case 'M':
			case 'D':
				printf(">");
				break;
			default:
				printf("%s",yytext);
			}
			}
%[<JALC]%" "?		{
			if (yyleng == 4)
				printf(" ");
			switch (yytext[1]) {
			case '<':
				printf("^");
				break;
			case 'J':
			case 'A':
				printf("[");
				break;
			case 'L':
			case 'C':
				printf("<");
				break;
			default:
				yytext[3] = '\0';
				printf("%s",yytext);
			}
			}
"="			printf(":");
"^"" "*			printf("\n");
"/\n"			printf("\n");
