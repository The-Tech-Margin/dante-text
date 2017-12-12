# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

# Request immediate notification of job completion.
set -b

PATH=$PATH:$HOME/bin:/opt/oracle/instantclient_12_2:/usr/sbin:.
export PATH

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/instantclient_12_2
export LD_LIBRARY_PATH

CDPATH=.:~:
export CDPATH

unset USERNAME

#ORACLE_HOME=/oracle
#export ORACLE_HOME

NLS_LANG=American_America.WE8ISO8859P1
export NLS_LANG

LANG=en_US.iso88591
export LANG

#SQLPATH="/home/dante/SQL:/home/stevec/OReilly"
SQLPATH=$HOME/SQL
export SQLPATH

DDP_STAGE=/var/www/html/ddp-stage

VIMRUNTIME=/usr/share/vim/vim63

TNSNAMES=/opt/oracle/instantclient_12_2/network/admin/tnsnames.ora
