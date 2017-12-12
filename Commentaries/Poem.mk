#
# Common poem cantica Makefile
#
# This Makefile gets included by a stub Makefile located in
# the poem's cantica directories. You can use the resulting Makefile
# to make (ie load) individual files in the cantica.
#

include		../Desc.mk

sources		:= $(wildcard *.e)
ldfiles		:= $(subst .e,.pld,$(sources))
datfiles	:= $(subst .e,.pdat,$(sources))

.SECONDARY:	$(subst .e,.pdat,$(sources))

all:	$(ldfiles)

dat:	$(datfiles)

clean:
	rm -f *.pdat *.pld *.log

include		../../Common.mk
