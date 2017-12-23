#
# Common rules for all DDP Makefiles
#
# This file, and only this file, tell how to load description,
# poem, and commentary text from .e files into the database.
#
# This file gets included from the Makefiles in the commentary
# and cantica directories.
#

#
# The following code uses command-line arguments to set the userid to use with Oracle.
# The resulting USERID should look like one of these:
#
#	dante/password@dante		# corresponds to the "copper" database
#	dante/password@dante_baseline	# tin
#	dante/password@dante_upgrade	# lead
#	dante/password@dante_silver	# silver (Obsolete)

ifndef USERID
        ifeq "$(DBNAME)" "tin"
                SERVICE = dante_baseline
        endif
        ifeq "$(DBNAME)" "copper"
                SERVICE = dante
        endif
        ifndef SERVICE
            $(error Unrecognized or missing value for DBNAME. Use DBNAME=tin or DBNAME=copper)
        endif
        ifndef PW
            $(error No password specified. Include PW=password on the command line)
        endif
        USERID = dante/$(PW)@$(SERVICE)
        export USERID
endif

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

#
# For commentary description (desc.e) files
#

%.cdat:	%.e
	rm -f $@
	ddp2html < $< | \
	ddp2descsql $(comm_id) $(comm_name) $(comm_lang) > $@

%.log:	%.cdat
	sqlplus $(USERID) @delete_desc $(comm_id)
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_comm_tab.ldrctl LOG=desc.log DATA=$< BAD=/dev/null

#
# For commentary text files
#

%.tdat:	%.e
	rm -f $@
	ddp2html < $< | \
	ddp2textsql $(relpath)/$*.e $(comm_id) $(comm_lang) $(cantica) $* > $@

%.log:	%.tdat
	sqlplus $(USERID) @delete_text $(relpath)/$*.e
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null

#
# For poem text files
#

%.pdat:	%.e
	rm -f $@
	ddp2html < $< | \
	ddp2poemsql $(relpath)/$< $(comm_id) $(comm_lang) $(cantica) $* > $@

%.log:	%.pdat
	sqlplus $(USERID) @delete_text $(relpath)/$*.e
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null
