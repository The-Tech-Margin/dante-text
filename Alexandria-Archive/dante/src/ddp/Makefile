DEST=/usr/local/bin
#CC=gcc
CFLAGS=-O 
#CFLAGS=-O -D_BSD

ddp:	ddp.o map.o
	cc $(CFLAGS) -o ddp ddp.o map.o -ll

install:	ddp
	install -c -m 755 -o dante ddp $(DEST)

clean:
	rm -f core errs *.o ddp

ddp.o:	map.h
