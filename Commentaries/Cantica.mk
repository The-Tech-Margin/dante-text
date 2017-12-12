#
# Common cantica Makefile
#
# This Makefile gets included by a stub Makefile located in
# each commentary's cantica directories. You can use the resulting Makefile
# to make (ie load) individual files in the cantica.
#

include		../Desc.mk

sources		:= $(wildcard *.e)
ldfiles		:= $(subst .e,.tld,$(sources))
datfiles	:= $(subst .e,.tdat,$(sources))

.SECONDARY:	$(subst .e,.tdat,$(sources))

all:	$(ldfiles)

dat:	$(datfiles)

clean:
	rm -f *.tdat *.tld *.log

include		../../Common.mk
