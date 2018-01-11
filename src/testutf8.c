#include <stdio.h>

/* See http://www.utf8-chartable.de/unicode-utf8-table.pl for UTF-8 encodings */

int
main() {
	printf("Here is an 'a' with acute accent - ");
	printf("%c%c", 0xc3, 0xa1);
	printf(".\n");
}
