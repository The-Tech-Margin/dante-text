SECTIONS	= title overview design processing \
		session futures notes commentaries

qtroff:	defs $(SECTIONS)
	m4 defs $(SECTIONS) | qtroff -me -J Zampolli

nroff:	defs $(SECTIONS)
	@m4 defs $(SECTIONS) | nroff -me

spell:	$(SECTIONS)
	spell $(SECTIONS)
