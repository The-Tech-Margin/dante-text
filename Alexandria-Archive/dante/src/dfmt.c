/*
 *	dfmt - Do a rought formatting of a file (Dante fmt)
 *
 *	Reads stdin and outputs lines of ~ 65 chars, breaking at
 *	word boundaries.  Useful for rough formatting of files
 *	from data entry agencies like CIC.
 */

#include <stdio.h>

main()
{
	register int c;
	register int linelen = 0;

	while ((c = fgetc(stdin)) != EOF) {
		if (c == '\r')
			continue;
		if (linelen > 65 && c == ' ')
			c = '\n';
		if (c == '\n')
			linelen = 0;
		else if (c == '\t')
			linelen += 8;
		else if (c == 0263)
			c = '|';
		(void) fputc(c, stdout);
		linelen++;
	}
	exit(0);
}
