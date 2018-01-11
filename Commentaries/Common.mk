#
# Common rules for all DDP Makefiles
#
# This file, and only this file, tell how to load description,
# poem, and commentary text from .e files into the database.
#
# This file gets included from the Makefiles in the commentary
# and cantica directories.
#

.PHONY:		reindex

#
# top level of the commentary text maintenance files - customize as needed for your installation
#
top	:= 	$(HOME)/Dante/dante-text

#
# Important directories and paths
#
ctldir	:=	$(top)/SQL
commdir	:=	$(top)/Commentaries/
abspath	:=	$(shell pwd)
cantica	:=	$(notdir $(abspath))
relpath	:=	$(subst $(commdir),,$(abspath))

include		$(commdir)/Userid.mk

#
# For commentary description (desc.e) files
#

%.cdat:	%.e
	rm -f $@
	ddp2html8 < $< | \
	ddp2descsql $(comm_id) $(comm_name) $(comm_lang) > $@

%.log:	%.cdat
	sqlplus $(USERID) @delete_desc $(comm_id)
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_comm_tab.ldrctl LOG=desc.log DATA=$< BAD=/dev/null

#
# For commentary text files
#

%.tdat:	%.e
	rm -f $@
	ddp2html8 < $< | \
	ddp2textsql $(relpath)/$*.e $(comm_id) $(comm_lang) $(cantica) $* > $@

%.log:	%.tdat
	sqlplus $(USERID) @delete_text $(relpath)/$*.e
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null

#
# For poem text files
#

%.pdat:	%.e
	rm -f $@
	ddp2html8 < $< | \
	ddp2poemsql $(relpath)/$< $(comm_id) $(comm_lang) $(cantica) $* > $@

%.log:	%.pdat
	sqlplus $(USERID) @delete_text $(relpath)/$*.e
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null

#
# To regenerate the full text index, such as after loading updates
#
reindex:
	sqlplus $(USERID) @reindex
