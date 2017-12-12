/*
 *	wordlist - generate a wordlist 
 *
 *	Usage: wordlist [file ...]
 *
 *	Copy text from the input file(s) (default is stdin) to stdout
 *	with 1 word per line in the output.  Diacritic markers are
 *	ignored.  Any punctuation or white space delimits a word.
 *
 *	Note: a comma *within* a word is a diacritic, so we elide it.
 *	If it is on fact at the end of a word, then the following
 *	white space will delimit the word anyway, so our misguess
 *	doesn't matter.
 */

#include <stdio.h>
#include <ctype.h>
#include <strings.h>

#define	DIACRITICS	"@$#,"
#define DEGREE		'+'

void
wordlist(f)
	FILE	*f;
{
	register int	c;
	register int	inword = 0;

	while ((c = getc(f)) != EOF) {
		if (isalpha(c)) {
			/*
			 * part of a word: output it.
			 */
			if (putc((char)c,stdout) == EOF)
				return;
			inword = 1;
		}
		else if (c == DEGREE ) {
			/*
			 * A degree character: eat the + and the character.
			 */
			c = getc(f);
		}
		else if (strchr(DIACRITICS,c)) {
			/*
			 * A diacritic: eat it.
			 */
		}
		else {
			/*
			 * punctuation or white space: end of word.
			 */
			if (inword) {
				if (putc('\n',stdout) == EOF)
					return;
				inword = 0;
			}
		}
	}
}
main(argc,argv)
	int	argc;
	char	**argv;
{
	FILE	*f;
	int	status = 0;

	if (argc == 1) {	/* no args - use stdin */
		wordlist(stdin);
		return(0);
	}
	while (--argc) {
		if ((f = fopen(*(++argv),"r")) == NULL) {
			perror(*argv);
			status = 1;
		}
		else {
			wordlist(f);
			(void)fclose(f);
		}
	}
	return(status);
}
