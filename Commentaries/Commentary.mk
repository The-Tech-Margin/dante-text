#
# Common commentary Makefile
#
# This Makefile gets included by a stub Makefile located in the poem's
# and each commentary's main directory. You use the resulting Makefile
# to make (ie load) the entire commentary or one of its canticas.
#

include		./Desc.mk

####
.PHONY:	all desc $(canticas) dat up-to-date clean

.SECONDARY:	desc.cdat

all:	desc $(top_level) $(canticas)

$(canticas):
	$(MAKE) --directory=$@ all

desc:	desc.log

dat:	desc.cdat $(top_level_dat)
	for d in $(canticas);			\
	do					\
		$(MAKE) --directory=$$d dat;	\
	done

up-to-date:
	touch desc.log $(top_level_log)
	for d in $(canticas);			\
	do					\
		$(MAKE) --directory=$$d up-to-date;	\
	done

clean:
	rm -f *.cdat *.tdat *.log
	for d in $(canticas);			\
	do					\
		$(MAKE) --directory=$$d clean;	\
	done

include		../Common.mk
