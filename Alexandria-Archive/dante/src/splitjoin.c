/* merge two files by lines */

#include <stdio.h>
#define CNTLL	'\n'

main(argc, argv)
int argc;
char *argv[];
{
	FILE *file1;
	FILE *file2;
	int more1 = 1;
	int more2 = 1;
	char name1[256];
	char name2[256];
	char c;

	if (argc != 3) {
		printf("Must have two arguments\n");
		exit();
	}

	strcpy(name1, argv[1]);
	strcpy(name2, argv[2]);

	if((file1 = fopen(name1, "r")) == NULL) {
		printf("Can't open file \"%s\";  Bye!\n", name1);
		exit();
	}
	if((file2 = fopen(name2, "r")) == NULL) {
		printf("Can't open file \"%s\";  Bye!\n", name2);
		exit();
	}

	while(more1 || more2) {
		while(((c=getc(file1)) != EOF) && (c != CNTLL)){
			putchar(c);
		}
		if (c != CNTLL) {
			more1 = 0;
		}
		putchar(c);
		while(((c=getc(file2)) != EOF) && (c != CNTLL)) {
			putchar(c);
		}
		if (c != CNTLL) {
			more2 = 0;
		}
		putchar(c);
	}
}
