CFLAGS=-O

todec:	main.o todec.o 
	cc $(LFLAGS) -o todec main.o todec.o -ll

install:	todec
	install todec /dante/bin

test:	todec /dante/doc/chartest.s 
	rm -f test.out 
	todec /dante/doc/chartest.s test.out
	cmp test.out test.out.canonical

clean:
	rm -f todec main.o core errs test.out
