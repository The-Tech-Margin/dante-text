/*
 * Correct a problem with LINE and ENDL in early output from dbloadf.
 *
 * Problem: when a document referred to a single poem line, dbloadf generated
 *
 *	LINE: n
 *
 * and no ENDL.  It should also have generated
 *
 *	ENDL: n
 *
 * so that line searches could always be expressed as
 *
 *	@LINE <= n AND n <= @ENDL
 *
 * The program is a straight filter, adding ENDL statements where they are
 * missing.  It assumes that the order of statements is:
 *
 *	LINE:
 *	m
 *	ENDL:
 *	n
 * or
 *	LINE:
 *	m
 *	TEXT:
 */

#include <stdio.h>

main()
{
	char line[256];
	int LINEval;
	int should;		/* true if next line should be ENDL */
	int getLINEval;		/* true if next line is the LINE value */
	int lineno;

	should = 0;
	getLINEval = 0;
	lineno = 0;
	while (fgets(line,sizeof(line),stdin) != NULL) {
		lineno++;
		if (getLINEval) {
			LINEval = -1;
			LINEval = atoi(line);
			if (LINEval <= 0)
				fprintf(stderr,"line %d: bogus LINE value\n",lineno);
			getLINEval = 0;
			should = 1;
		} else if (should) {
			if (strncmp(line,"..ENDL",6))
				fprintf(stdout,"..ENDL:\n%d\n",LINEval);
			should = 0;
		} else if (!strncmp(line,"..LINE",6)) {
			getLINEval = 1;
		}
		fputs(line,stdout);
	}
	exit(0);
}
