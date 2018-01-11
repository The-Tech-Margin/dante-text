%{
/*
 *	ddp2html8 - a filter to convert DDP markup to HTML markup and UTF-8 characters
 *
 *	Old DDP markups for accents, umlauts, and circumflexes are converted into
 *	their UTF-8 characters. Other graphics, font changes, and Greek characters
 *	are converted into their HTML entities.
 *
 *	This program is adapted from ddp2html.l, which did much the same but generated
 *	ISO-8859-9 characters instead of UTF-8.
 *
 *	Compile with 'make LDLIBS=-ll ddp2html8' and move the executable to ~/bin.
 */
#define	MAXFONT	3
char	*font[MAXFONT];		/* remembers what type of font we are in */
int	fontp = 0;		/* current font; 0 implies plain font */
/*
 * The next variables keep track of left and right double quotes.
 */
char	*dquot[] = {"&ldquo;", "&rdquo;"};
int	dquot_toggle = 0;
%}
%%

\\. {
	/*
	 * Any escaped character, ie preceded by a backslash, is itself.
	 */
	printf("%c", yytext[1]);
}
\\$ {
	/*
	 * An escaped end-of-line gets ignored.
	 */
}
\%[A-Za-z]+ {
	/*
	 * Greek
	 *
	 * Plain Greek letters are represented by their HTML entities, e.g. "&alpha;".
	 * The DDP files have these as a percent followed (mostly) by the name of the
	 * character. Since the HTML entity names are also the names of the characters,
	 * we can translate from DDP to HTML with a generalized rule and not examine
	 * individual character names.
	 *
	 * Greek letters may also be accented in the DDP files by inserting a $, @ or #
	 * between the % and the letter name. A $ implies an oxia, a @ implies
	 * a dasia, and a # implies a vrachy. There are no named HTML entities
	 * for these accented characters, so we use their Unicode numeric values, e.g.
	 * "&#x1F01;", which is an alternative entity notation that browsers will honor.
	 * We have to handles these individually, i.e. by enumeration. But there are not
	 * many in the DDP text, so it's not a big deal.
	 *
	 * See: http://www.utf8-chartable.de/unicode-utf8-table.pl, and select the "Greek
	 * Extended" block.
	 *
	 * Match Greek before Latin characters so (for example) %$alpha isn't matched
	 * as a % followed by an accented Latin "a".
	 *
	 */

	/*
	 * Unaccented Greek
	 */
	if (!strcmp(yytext,"%o")) {
		printf("&omicron;");
	} else if (!strcmp(yytext,"%O")) {
		printf("&Omicron;");
	} else if (!strncmp(yytext,"%var",4)) {
		printf("&%s;", yytext+4);
	} else {
		printf("&%s;", yytext+1);
	}
}
\%[\$@#]+[A-Za-z]+ {
	/*
	 * Accented Greek
	 */
	if (!strcmp(yytext,"%$epsilon") | !strcmp(yytext,"%$varepsilon")) {
		printf("&#x1F73;");
	} else if (!strcmp(yytext,"%@epsilon") | !strcmp(yytext,"%@varepsilon")) {
		printf("&#x1F11;");
	} else if (!strcmp(yytext,"%@alpha")) {
		printf("&#x1F01;");
	} else if (!strcmp(yytext,"%$alpha")) {
		printf("&#x1F71;");
	} else if (!strcmp(yytext,"%#alpha")) {
		printf("&#x1FB0;");
	} else if (!strcmp(yytext,"%@$varepsilon")) {
		printf("&#x1F15;");
	} else if (!strcmp(yytext,"%@omicron") | !strcmp(yytext,"%@o")) {
		printf("&#x1F41;");
	} else if (!strcmp(yytext,"%$omicron") | !strcmp(yytext,"%$o")) {
		printf("&#x1F79;");
	} else if (!strcmp(yytext,"%$eta")) {
		printf("&#x1F75;");
	} else if (!strcmp(yytext,"%@eta")) {
		printf("&#x1F21;");
	} else if (!strcmp(yytext,"%@E")) {
		printf("&#x1F29;");
	} else if (!strcmp(yytext,"%$E")) {
		printf("&#x1FCB;");
	} else if (!strcmp(yytext,"%$iota")) {
		printf("&#x1F77;");
	} else if (!strcmp(yytext,"%@iota")) {
		printf("&#x1F31;");
	} else if (!strcmp(yytext,"%#iota")) {
		printf("&#x1FD0;");
	} else if (!strcmp(yytext,"%@upsilon")) {
		printf("&#x1F51;");
	} else if (!strcmp(yytext,"%$upsilon")) {
		printf("&#x1F7B;");
	} else if (!strcmp(yytext,"%#upsilon")) {
		printf("&#x1FE0;");
	} else if (!strcmp(yytext,"%$omega")) {
		printf("&#x1F7D;");
	}
}
	/*
	 * Translate regular Latin characters with diacritics into their UTF-8 form.
	 * See http://www.utf8-chartable.de/unicode-utf8-table.pl and use the UTF-8 (hex.) form.
	 * (Many of these also have HTML entities, but we want the words that contain these
	 * characters to be searchable in the database, so we want a character, not an entity.)
	 */
@[A-Za-z] {
	/*
	 * Grave accents
	 */
	switch (yytext[1]) {
	case 'a': printf("%c%c", 0xc3, 0xa0); break;
	case 'A': printf("%c%c", 0xc3, 0x80); break;
	case 'e': printf("%c%c", 0xc3, 0xa8); break;
	case 'E': printf("%c%c", 0xc3, 0x88); break;
	case 'i': printf("%c%c", 0xc3, 0xac); break;
	case 'I': printf("%c%c", 0xc3, 0x8c); break;
	case 'o': printf("%c%c", 0xc3, 0xb2); break;
	case 'O': printf("%c%c", 0xc3, 0x92); break;
	case 'u': printf("%c%c", 0xc3, 0xb9); break;
	case 'U': printf("%c%c", 0xc3, 0x99); break;
	default: printf("%s",yytext);
	}
}
\$[A-Za-z] {
	/*
	 * Acute accents and cedillas
	 */
	switch (yytext[1]) {
	case 'a': printf("%c%c", 0xc3, 0xa1); break;
	case 'A': printf("%c%c", 0xc3, 0x81); break;
	case 'e': printf("%c%c", 0xc3, 0xa9); break;
	case 'E': printf("%c%c", 0xc3, 0x89); break;
	case 'i': printf("%c%c", 0xc3, 0xad); break;
	case 'I': printf("%c%c", 0xc3, 0x8d); break;
	case 'o': printf("%c%c", 0xc3, 0xb3); break;
	case 'O': printf("%c%c", 0xc3, 0x93); break;
	case 'u': printf("%c%c", 0xc3, 0xba); break;
	case 'U': printf("%c%c", 0xc3, 0x9a); break;
	case 'c': printf("%c%c", 0xc3, 0xa7); break;
	case 'C': printf("%c%c", 0xc3, 0x87); break;
	/*
	 * Strange though it seems, acute accented "q" appears in Daniello. To create this,
	 * we print the "q" and follow it with a "combining acute accent," Unicode U+0301.
	 */
	case 'q': printf("q%c%c", 0xcc, 0x81); break;
	default: printf("%s",yytext);
	}
}
,[A-Za-z] {
	/*
	 * Umlauts, also known as diaeresis marks
	 */
	switch (yytext[1]) {
	case 'a': printf("%c%c", 0xc3, 0xa4); break;
	case 'A': printf("%c%c", 0xc3, 0x84); break;
	case 'e': printf("%c%c", 0xc3, 0xab); break;
	case 'E': printf("%c%c", 0xc3, 0x8b); break;
	case 'i': printf("%c%c", 0xc3, 0xaf); break;
	case 'I': printf("%c%c", 0xc3, 0x8f); break;
	case 'o': printf("%c%c", 0xc3, 0xb6); break;
	case 'O': printf("%c%c", 0xc3, 0x96); break;
	case 'u': printf("%c%c", 0xc3, 0xbc); break;
	case 'U': printf("%c%c", 0xc3, 0x9c); break;
	default: printf("%s",yytext);
	}
}
#[A-Za-z] {
	/*
	 * Circumflex
	 */
	switch (yytext[1]) {
	case 'a': printf("%c%c", 0xc3, 0xa2); break;
	case 'A': printf("%c%c", 0xc3, 0x82); break;
	case 'e': printf("%c%c", 0xc3, 0xaa); break;
	case 'E': printf("%c%c", 0xc3, 0x8a); break;
	case 'i': printf("%c%c", 0xc3, 0xae); break;
	case 'I': printf("%c%c", 0xc3, 0x8e); break;
	case 'o': printf("%c%c", 0xc3, 0xb4); break;
	case 'O': printf("%c%c", 0xc3, 0x94); break;
	case 'u': printf("%c%c", 0xc3, 0xbb); break;
	case 'U': printf("%c%c", 0xc3, 0x9b); break;
	default: printf("%s",yytext);
	}
}
-- {
	/*
	 * En dash
	 */
	printf("&ndash;");
}
& {
	/*
	 * Ampersand
	 */
	printf("&amp;");
}
\` {
	/*
	 * Single left quotation mark
	 * This is just a clean-up conversion.
	 */
	printf("'");
}
\" {
	/*
	 * Left and right double quotation marks
	 */
	printf("%s",dquot[dquot_toggle]);
	dquot_toggle = (dquot_toggle+1) % 2;
}
\< {
	/*
	 * Left angle quote
	 */
	printf("&laquo;");
}
\> {
	/*
	 * Right angle quote
	 */
	printf("&raquo;");
}
\| {
	/*
	 * Begin bold font
	 */
	if (fontp < MAXFONT) {
		printf("<b>");
		font[++fontp] = "b";
	}
}
\^ {
	/*
	 * Begin italics font
	 */
	if (fontp < MAXFONT) {
		printf("<i>");
		font[++fontp] = "i";
	}
}
\+ {
	/*
	 * Begin superscript
	 */
	if (fontp < MAXFONT) {
		printf("<sup>");
		font[++fontp] = "sup";
	}
}
~ {
	/*
	 * End special font
	 */
	for (; fontp > 0; fontp--) {
		printf("</%s>", font[fontp]);
	}
}
