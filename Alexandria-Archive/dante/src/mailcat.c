/*
 *	mailcat - copy stdin to a file, end with a line with just a dot
 *
 *	Usage: mailcat	file
 *
 *	Stdin is copied to the file until a line consisting of only a dot
 *	is typed.  Like the mail command does.  Used by the ddp mail menu.
 */
#include <stdio.h>

main(argc,argv)
	int argc;
	char **argv;
{
	FILE	*outf;
	char	line[150];

	if (argc != 2) {
		fprintf(stderr,"usage: %s filename\n",*argv);
		exit(1);
	}
	if ((outf = fopen(*++argv,"w")) == NULL) {
		perror(*argv);
		exit(1);
	}
	while (fgets(line,sizeof(line),stdin) != NULL) {
		if (strcmp(line,".\n") == 0)
			break;
		fputs(line,outf);
	}
	fclose(outf);
	exit(0);
}
