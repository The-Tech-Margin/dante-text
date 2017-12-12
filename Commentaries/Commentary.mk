#
# Common commentary Makefile
#
# This Makefile gets included by a stub Makefile located in the poem's
# and each commentary's main directory. You can use the resulting Makefile
# to make (ie load) the entire commentary or one of its canticas.
#

include		./Desc.mk

####
.PHONY:	all desc $(canticas)

.SECONDARY:	desc.cdat

all:	desc $(top_level) $(canticas)

desc:	desc.cld

dat:	desc.cdat $(top_level_dat) $(canticas)

$(canticas):
	$(MAKE) --directory=$@ $(TARGET)

clean:
	rm -f *.cdat *.tdat *.cld *.tld *.log
	for d in $(canticas);			\
	do					\
		$(MAKE) --directory=$$d clean;	\
	done

include		../Common.mk
