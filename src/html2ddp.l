
%%

\<i>			printf("^");

\<b>			printf("|");

\<sup>			printf("+");

\<\/i>|\<\/b>|\<\/sup>	printf("~");

\<[^>]*>		/* ignore all other html markup */

\|			printf("\\|");

&[rl]squo;		printf("'");

&[rl]dquo;		printf("\"");

&.grave;		printf("@%c", yytext[1]);

&.acute;		printf("$%c", yytext[1]);

&.uml;			printf(",%c", yytext[1]);

&hellip;		printf("...");

&ndash;			printf("-");

&quot;			printf("\"");

%%

int main() {
    while (yylex());
    return 0;
}

int yywrap() {
    return 1;
}

