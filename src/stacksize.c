/*
 * Play with pthread_attr_[get/set]stacksize. (For use with DBSD.)
 *
 * Compile with -lpthread.
 */

#include	<stdio.h>
#include	<pthread.h>
#include	<assert.h>

int
main(void)
{
	pthread_attr_t	attr;
	size_t		stacksize = 0;

	assert(!pthread_attr_init(&attr));
	assert(!pthread_attr_getstacksize(&attr, &stacksize));
	printf("default stacksize is %d\n", stacksize);

	return 0;
}
