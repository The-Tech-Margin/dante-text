#
# Common rules for all DDP Makefiles
#
# This file, and only this file, tell how to generate
# description, poem, and commentary text load files from .e files,
# and how to load descriptions and commentary text and
# generate the corresponding "loaded" (.cld, .pld, and .tld) files.
#
# This file gets included from the Makefiles in the commentary
# and cantica directories.
#

#
# The following code uses command-line arguments to set the userid to use with Oracle.
# The resulting USERID should look like one of these:
#
#userid	:=	dante/password@dante		# corresponds to the "copper" database
#userid	:=	dante/password@dante_baseline	# tin
#userid :=	dante/password@dante_upgrade	# lead
#userid	:=	dante/password@dante_silver	# silver (Obsolete)

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
# top level of the commentary text maintenance files
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

%.cld:	%.cdat
	if [ -f $@ ];		\
	then			\
		sqlplus $(USERID) @delete_desc $(comm_id) && rm -f $@;	\
	else			\
		true;		\
	fi
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_comm_tab.ldrctl LOG=desc.log DATA=$< BAD=/dev/null
	touch $@

#
# For commentary text files
#

%.tdat:	%.e
	rm -f $@
	ddp2html < $< | \
	ddp2textsql $(relpath)/$*.e $(comm_id) $(comm_lang) $(cantica) $* > $@

%.tld:	%.tdat
	if [ -f $@ ];		\
	then			\
		sqlplus $(USERID) @delete_text $(relpath)/$*.e && rm -f $@;	\
	else			\
		true;		\
	fi
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null
	touch $@

#
# For poem text files
#

%.pdat:	%.e
	rm -f $@
	ddp2html < $< | \
	ddp2poemsql $(relpath)/$< $(comm_id) $(comm_lang) $(cantica) $* > $@

%.pld:	%.pdat
	if [ -f $@ ];		\
	then			\
		sqlplus $(USERID) @delete_text $(relpath)/$*.e && rm -f $@;	\
	else			\
		true;		\
	fi
	sqlldr USERID=$(USERID) CONTROL=$(ctldir)/ddp_text_tab.ldrctl LOG=$*.log DATA=$< BAD=/dev/null
	touch $@
