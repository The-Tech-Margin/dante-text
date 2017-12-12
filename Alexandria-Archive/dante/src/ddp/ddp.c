/*
 *	ddp - interface to BRS for the Dartmouth Dante Project
 *
 *	Usage:	ddp [-x] [-t term] [-u user]
 *
 *	If the user's terminal can not accept the escapes, then ddp just
 *	execs BRS as if it were invoked directly.  Otherwise ddp sets itself
 *	up as a filter between the user and BRS, so it can translate escape
 *	sequences that come out of the database into the appropriate chars.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/errno.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <sys/wait.h>
#include <sgtty.h>
#include <signal.h>
#include <string.h>
#include "map.h"

#define	USAGE	"Usage: ddp  [-x] [-t term] [-u user]\n"
#define DFLTBRS	"/1g/BRS"
#define BRSMAIN	"Bin/brsmain"

char	*menu = "MAIN_";
int	child;
char	*uflag, *username;
char	brspgm[100];
void	onsusp();
void	deadchild();

int	masterfd, slavefd;

main(argc, argv)
	int argc;
	char **argv;
{
	extern	char *optarg;
	extern	int  optind;
	char *getenv();
	int c;
	char *termname = NULL;
	char *brsdir;

	while ((c = getopt(argc,argv,"xt:u:")) != EOF)
		switch (c) {
		case 'x':
			/*
			 * -x means use the experimental main BRS MNS menu.
			 */
			menu = "XMAIN_";
			break;
		case 't':
			termname = optarg;
			break;
		case 'u':
			username = optarg;
			uflag = "-log";
			break;
		default:
			fputs(USAGE,stderr);
			exit(1);
			/*NOTREACHED*/
		}
	if (!termname)
		termname = getenv("TERM");

	if ((brsdir = getenv("Brs")) == NULL)
		brsdir = DFLTBRS;
	(void)sprintf(brspgm,"%s/%s",brsdir,BRSMAIN);

	/*
	 * figure out if this terminal can take special characters,
	 * and if so, which set.  See /etc/termcap for terminal names.
	 */
	if (termname && *termname) {
		/*
		 * VT2XX or VT3XX or VT4XX?
		 */
		if (!strncmp(termname,"vt2",3) ||
		    !strncmp(termname,"vt3",3) ||
		    !strncmp(termname,"vt4",3) ||
		   (termname[0] == 'd' &&
		    termname[1] >= 'l' &&
		    termname[1] <= 'o')) {
			termtype = MAP_VT200;
		} else
		/*
		 * IBM PC?
		 */
		if (!strcmp(termname,"pc") || !strcmp(termname,"ibmpc")) {
			termtype = MAP_IBMPC;
		}
	}

	if (termtype == MAP_NOMAP) {
#ifdef notdef
		fprintf(stderr,"exec (no filter): %s %s %s %s %s %s %s\n",brspgm,"-dir","DDP","-menu",menu,uflag,username);
#endif
		execl(brspgm,"brsmns","-dir","DDP","-menu",menu,uflag,username,0);
		perror(brspgm);
		exit (1);
		/*NOTREACHED*/
	}

	if (openpty(&masterfd,&slavefd,NULL,NULL,NULL) < 0) {
		perror("openpty");
		exit(1);
		/*NOTREACHED*/
	}

	(void) signal(SIGCHLD, deadchild);
	if ((child = fork()) < 0) {
		perror("first fork");
		exit(1);
		/*NOTREACHED*/
	}
	if (child == 0) {
		if ((child = fork()) < 0) {
			perror("second fork");
			exit(1);
			/*NOTREACHED*/
		}
		if (child == 0) {
			(void) close(masterfd);
			dobrs();
		} else {
			signal(SIGINT,SIG_IGN);
			dooutput(masterfd);
		}
	} else {
		fixtty();
		signal(SIGINT,SIG_IGN);
		signal(SIGTSTP,onsusp);
		doinput(masterfd);
		restoretty();
	}
	exit(0);
	/*NOTREACHED*/
}

doinput(master)
	int master;
{
	char ibuf[BUFSIZ];
	int cc;

	while ((cc = read(0, ibuf, BUFSIZ)) > 0) {
		if (ibuf[cc-1] == '\n')
			if (write(1, "\r", 1) < 0)	/* compensate for LITOUT */
				break;
		if (write(master, ibuf, cc) < 0)
			break;
	}
	(void) close(master);
}

dooutput(master)
	int master;
{
	char abuf[BUFSIZ], bbuf[BUFSIZ];
	register char *ap, *bp;
	int cc;

	/*
	 * Read into only a portion of abuf to allow room for expansion.
	 */
	while ((cc = read(master, abuf, (sizeof abuf) / 2)) > 0) {
		*(abuf + cc) = '\0';
		lexinp = abuf;
		lexoutp = bbuf;
		yylex();
		for (ap = abuf, bp = bbuf; bp < lexoutp; ) {
			if ((*ap++ = *bp++) == '\n') {
				*ap++ = '\r';
			}
		}
		if (write(1, abuf, (int)(ap - abuf)) < 0)
			break;
	}
}

dobrs()
{
	dup2(slavefd, 0);
	dup2(slavefd, 1);
	dup2(slavefd, 2);
	(void) close(slavefd);
#ifdef notdef
	fprintf(stderr,"exec (filter): %s %s %s %s %s %s %s\n",brspgm,"-dir","DDP","-menu",menu,uflag,username);
#endif
	execl(brspgm,"brsmain","-dir","DDP","-menu",menu,uflag,username,0);
	perror(brspgm);
	exit(1);
	/*NOTREACHED*/
}



void
deadchild()
{
	int status;

	if (wait3(&status, WNOHANG, (struct rusage *)0) != child)
		return;
	restoretty();
	exit(0);
	/*NOTREACHED*/
}

int lword;

fixtty()
{
	int newlbits = LLITOUT;

	if(ioctl(1,TIOCLGET, (char *)&lword) < 0) {
		perror("fixtty: TIOCLGET");
		exit(1);
		/*NOTREACHED*/
	}
	if(ioctl(1,TIOCLBIS, (char *)&newlbits) < 0) {
		perror("fixtty: TIOCLBIS");
		exit(1);
		/*NOTREACHED*/
	}
	if (write(1,terminit(),strlen(terminit())) < 0) {
		perror("fixtty: write failed");
		exit(1);
		/*NOTREACHED*/
	}
}

restoretty()
{
	if (write(1,termdeinit(),strlen(termdeinit())) < 0) {
		perror("restoretty: write failed");
		exit(1);
		/*NOTREACHED*/
	}
	if(ioctl(1,TIOCLSET, (char *)&lword) < 0) {
		perror("restoretty: TIOCLSET");
		exit(1);
		/*NOTREACHED*/
	}
	if (write(1,"\n",1) < 0) {
		perror("restoretty: write failed");
		exit(1);
		/*NOTREACHED*/
	}
}



void
onsusp ()
{
	/*
	 * ignore SIGTTOU so we don't get stopped if csh grabs the tty
	 */
	signal(SIGTTOU, SIG_IGN);
	restoretty();
	fflush (stdout);
	signal(SIGTTOU, SIG_DFL);
	/*
	 * Send the TSTP signal to suspend our process group
	 */
	signal(SIGTSTP, SIG_DFL);
	sigsetmask(0);
	kill (0, SIGTSTP);
	/*
	 * Here is where we stop, and then restart...
	 */
	signal (SIGTSTP, onsusp);
	fixtty();
return;
}
