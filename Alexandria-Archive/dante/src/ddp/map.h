/*
 *	Common variables for selecting what kind of terminal we
 *	should translate escape sequences for.
 */

/*
 *	Possible values for termtype
 */
#define MAP_NOMAP	-1	/* Initial value - error if used */
#define MAP_VT200	0
#define MAP_IBMPC	1

#ifdef	THIS_IS_MAP
	int termtype = MAP_NOMAP;
	char *lexinp, *lexoutp;
	unsigned char *terminit(), *termdeinit();
#else
extern	int termtype;
extern	char *lexinp, *lexoutp;
extern	unsigned char *terminit(), *termdeinit();
#endif
