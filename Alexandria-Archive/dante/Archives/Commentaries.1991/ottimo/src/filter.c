# include "stdio.h"
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,yyout)
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
# define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng; extern char yytext[];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin ={stdin}, *yyout ={stdout};
extern int yylineno;
struct yysvf { 
	struct yywork *yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;
#include <ctype.h>
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
int upper = 0;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:
		printf("\n");
break;
case 2:
		;
break;
case 3:
	;
break;
case 4:
	;
break;
case 5:
	{
			printf("\n");
			yytext[yyleng-1] = '\0';
			printf(" %s",yytext+1);
			}
break;
case 6:
	{
			yytext[yyleng-1] = '\0';
			printf(" %s",yytext+1);
			}
break;
case 7:
		upper = 1;
break;
case 8:
	{
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
break;
case 9:
		printf("`");
break;
case 10:
		printf("'");
break;
case 11:
		printf(">");
break;
case 12:
		printf("-");
break;
case 13:
		printf("\n--");
break;
case 14:
		printf(".");
break;
case 15:
		printf("<");
break;
case 16:
	{
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
break;
case 17:
	{
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
break;
case 18:
		printf(":");
break;
case 19:
		printf("\n");
break;
case 20:
		printf("\n");
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */
int yyvstop[] ={
0,

15,
0,

7,
0,

9,
0,

10,
0,

11,
0,

12,
0,

14,
0,

18,
0,

8,
0,

19,
0,

13,
0,

1,
0,

2,
9,
0,

20,
0,

8,
0,

1,
0,

2,
0,

6,
0,

4,
0,

3,
0,

17,
0,

16,
0,

5,
6,
0,

4,
0,

3,
0,

17,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] ={
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	8,26,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	1,3,	
1,4,	1,5,	1,6,	16,16,	
2,18,	19,29,	20,30,	1,7,	
22,32,	23,33,	24,34,	25,35,	
1,8,	32,37,	1,9,	1,10,	
1,11,	2,19,	2,20,	33,38,	
1,12,	1,13,	34,39,	0,0,	
0,0,	0,0,	1,14,	0,0,	
0,0,	0,0,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
1,15,	1,15,	1,15,	1,15,	
21,31,	28,36,	0,0,	1,16,	
1,17,	4,21,	4,21,	4,21,	
4,21,	4,21,	4,21,	4,21,	
4,21,	4,21,	4,21,	15,27,	
0,0,	0,0,	0,0,	0,0,	
15,27,	0,0,	0,0,	0,0,	
4,21,	4,21,	0,0,	0,0,	
0,0,	15,27,	4,21,	4,21,	
5,22,	5,22,	5,22,	5,22,	
5,22,	5,22,	5,22,	5,22,	
5,22,	5,22,	0,0,	4,21,	
0,0,	4,21,	6,23,	6,23,	
0,0,	0,0,	6,24,	0,0,	
6,25,	0,0,	0,0,	6,24,	
6,25,	6,24,	6,25,	0,0,	
0,0,	0,0,	0,0,	0,0,	
6,24,	6,25,	6,24,	6,25,	
18,28,	18,28,	18,28,	18,28,	
18,28,	18,28,	18,28,	18,28,	
18,28,	18,28,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	18,28,	
18,28,	0,0,	0,0,	0,0,	
0,0,	18,28,	18,28,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	18,28,	0,0,	
18,28,	0,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] ={
0,	0,	0,
yycrank+1,	0,		0,	
yycrank+5,	yysvec+1,	0,	
yycrank+0,	0,		yyvstop+1,
yycrank+49,	0,		0,	
yycrank+76,	0,		0,	
yycrank+82,	0,		0,	
yycrank+0,	0,		yyvstop+3,
yycrank+7,	0,		0,	
yycrank+0,	0,		yyvstop+5,
yycrank+0,	0,		yyvstop+7,
yycrank+0,	0,		yyvstop+9,
yycrank+0,	0,		yyvstop+11,
yycrank+0,	0,		yyvstop+13,
yycrank+0,	0,		yyvstop+15,
yycrank+69,	0,		yyvstop+17,
yycrank+7,	0,		yyvstop+19,
yycrank+0,	0,		yyvstop+21,
yycrank+112,	0,		0,	
yycrank+9,	0,		yyvstop+23,
yycrank+10,	0,		yyvstop+25,
yycrank+28,	yysvec+4,	0,	
yycrank+8,	yysvec+5,	0,	
yycrank+8,	0,		0,	
yycrank+9,	0,		0,	
yycrank+10,	0,		0,	
yycrank+0,	0,		yyvstop+28,
yycrank+0,	0,		yyvstop+30,
yycrank+29,	yysvec+18,	0,	
yycrank+0,	0,		yyvstop+32,
yycrank+0,	0,		yyvstop+34,
yycrank+0,	0,		yyvstop+36,
yycrank+17,	0,		yyvstop+38,
yycrank+23,	0,		yyvstop+40,
yycrank+26,	0,		yyvstop+42,
yycrank+0,	0,		yyvstop+44,
yycrank+0,	0,		yyvstop+46,
yycrank+0,	0,		yyvstop+49,
yycrank+0,	0,		yyvstop+51,
yycrank+0,	0,		yyvstop+53,
0,	0,	0};
struct yywork *yytop = yycrank+200;
struct yysvf *yybgin = yysvec+1;
char yymatch[] ={
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,'&' ,01  ,
01  ,01  ,01  ,'&' ,01  ,01  ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'4' ,'0' ,'0' ,'0' ,
'8' ,'8' ,01  ,01  ,'<' ,01  ,'>' ,01  ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'E' ,'E' ,
'E' ,'I' ,'C' ,'B' ,'A' ,'B' ,'E' ,'E' ,
'E' ,'E' ,'E' ,'E' ,'E' ,'E' ,'I' ,'E' ,
'I' ,'E' ,'E' ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
0};
char yyextra[] ={
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
/*	ncform	4.1	83/08/11	*/

int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
char yytext[YYLMAX];
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
yylook(){
	register struct yysvf *yystate, **lsp;
	register struct yywork *yyt;
	struct yysvf *yyz;
	int yych;
	struct yywork *yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == yycrank){		/* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == yycrank)break;
				}
			*yylastch++ = yych = input();
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
			if ( (int)yyt > (int)yycrank){
				yyt = yyr + yych;
				if (yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)yyt < (int)yycrank) {		/* r < yycrank */
				yyt = yyr = yycrank+(yycrank-yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		if (yytext[0] == 0  /* && feof(yyin) */)
			{
			yysptr=yysbuf;
			return(0);
			}
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
yyback(p, m)
	int *p;
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
yyinput(){
	return(input());
	}
yyoutput(c)
  int c; {
	output(c);
	}
yyunput(c)
   int c; {
	unput(c);
	}
