/*
 *	Scan files for any non-ASCII character, e.g. ISO-8859. Report the name
 *	of any file  line number(s) where non-ASCII characters occur.
 *
 *	Usage: nonascii [file ...]
 */

#include <stdio.h>

void
doit(FILE * stream, char * fname)
{
	register int	c;
	int		lineno;

	lineno = 1;
	while ((c = fgetc(stream)) != EOF) {
		if (c == '\n') {
			lineno++;
		} else if (! isascii(c)) {
			if (*fname) printf("%s: ", fname);
			printf("%i\n", lineno);
		}
	} 
}

main(int argc, char **argv)
{
	FILE	*stream;
	int	printnames = argc > 2;
	int	errs = 0;

	if (argc == 1) {
		doit(stdin,"");
		return(0);
	} else {
		while (--argc) {
			if ((stream = fopen(*++argv,"r")) == NULL) {
				perror(*argv);
				errs = 1;
				continue;
			}
			doit(stream,printnames ? *argv : "");
			(void)fclose(stream);
		}
		if (errs)
			return(2);
		else
			return(0);
	}
}
