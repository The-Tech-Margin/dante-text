%{
#define TEXT 0
#define INDENT 1
#define	TILDE	'~'
#define BAR	'|'
#define CARET	'^'
#define SUPER	'+'
#define GREEK	'%'

int lines=0;
int font=0;
%}

%%
^\n$	{
	checkfonts(TEXT);
	lines++;
	}

^" "+	{
	countfonts();
	lines++;
	checkfonts(INDENT);
	}

^[^ ]+	{
	countfonts();
	lines++;
	}

%%
checkfonts(type)
int type;
{
	switch (type) {
		case INDENT:
			printf("%s", "Indent Error: ");
		case TEXT:
			printf("%s", "Error: ");
	}
	if (font > 0)
		printf("%s %d\n", "Too many font openings at line", lines);
	else if (font < 0 )
		printf("%s %d\n", "Too many font closings at line", lines);
	font = 0;
}

countfonts(){
	char *p;
	for (p = yytext; *p ; p++) {
		switch (*p) {
			case GREEK :
				printf("%s\n", "Warning: Greek font");
			case BAR :
			case CARET :
			case SUPER :
				font++;
				break;
			case TILDE :
				font--;
				break;
			default:
				break;
		}
	}
}
