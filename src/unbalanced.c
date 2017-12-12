/*
 *	Scana file for single and double quotes (' and "). Report the name
 *	of any file where the quotes are not balanced, i.e. appear in pairs.
 *
 *	MODIFIED for Dante by NOT checking single quotes. There are many in the DDP.
 *
 *	Usage: unbalanced [file ...]
 */

#include <stdio.h>

int
doit(FILE * stream, char * fname)
{
	register int	c;
	int		singles, doubles;

	singles = doubles = 0;
	do {
		c = fgetc(stream);
		switch (c) {
			/*
			case '\'':	singles = (singles + 1) % 2;
					break;
			*/
			case '"':	doubles = (doubles + 1) % 2;
					break;
		}
	} while (c != EOF);

	if (singles + doubles) {
		if (*fname)
			printf("%s\n", fname);
		return(1);
	}
	else
		return(0);
}

main(int argc, char **argv)
{
	FILE	*stream;
	int	printnames = argc > 2;
	int	errs = 0;
	int	status = 0;

	if (argc == 1)
		return(doit(stdin,""));
	else
		while (--argc) {
			if ((stream = fopen(*++argv,"r")) == NULL) {
				perror(*argv);
				errs = 1;
				continue;
			}
			status =+ doit(stream,printnames ? *argv : "");
			(void)fclose(stream);
		}
	if (errs)
		return(2);
	else if (status)
		return(1);
	else
		return(0);
}
