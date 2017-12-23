#
# Common cantica Makefile
#
# This Makefile gets included by a stub Makefile located in
# each commentary's cantica directories. You use the resulting Makefile
# to make (ie load) individual files in the cantica.
#

include		../Desc.mk

sources		:= $(wildcard *.e)
logfiles	:= $(subst .e,.log,$(sources))
datfiles	:= $(subst .e,.tdat,$(sources))

.SECONDARY:	$(subst .e,.tdat,$(sources))

all:	$(logfiles)

dat:	$(datfiles)

up-to-date:
	touch $(logfiles)

clean:
	rm -f *.tdat *.log

include		../../Common.mk
