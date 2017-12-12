/* The operator types an 8-bit value in hex; the program displays the char */

#include <stdio.h>

main()
{
	int value;

	printf("Type pairs of hexadecimal digits (00 to quit) followed by CR.\n");
	for (;;) {
		fputs(">",stdout);
		if (scanf("%x", &value) != 1) {
			value = '?';
			while (getchar() != '\n') ;
			continue;
		}
		if (!value)
			break;
		printf("\r\nhex = %02x, char = '%c'\r\n", value, (char)value);
	}
}
