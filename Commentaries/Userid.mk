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
