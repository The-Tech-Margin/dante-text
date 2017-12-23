#
# Common poem cantica Makefile
#
# This Makefile gets included by a stub Makefile located in
# the poem's cantica directories. You use the resulting Makefile
# to make (ie load) individual files in the cantica.
#

include		../Desc.mk

sources		:= $(wildcard *.e)
logfiles	:= $(subst .e,.log,$(sources))
datfiles	:= $(subst .e,.pdat,$(sources))

.SECONDARY:	$(subst .e,.pdat,$(sources))

all:	$(logfiles)

dat:	$(datfiles)

up-to-date:
	touch $(logfiles)

clean:
	rm -f *.pdat *.log

include		../../Common.mk
