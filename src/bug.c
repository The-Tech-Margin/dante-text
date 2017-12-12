#include <stdio.h>
enum party { dem, rep, ind };
struct ABC
	{ const char *name; party affil; } A[] =
{
	{ "Mary Smith", rep },
	{ "jack Spratt", dem },
	{ "Arch Emides", ind },
	{ (char *)0, (party)0 }
	/* ... */
};
int main ()
	{
	struct ABC *p;
	for ( p = A; p->name; p++ )
		{
		if ( p->affil == ind )
			printf( "%s (ind)\n", p->name );
		}
	return 0;
}
