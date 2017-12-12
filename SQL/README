This file gives an overview of the SQL schema that constitute the
Dartmouth Dante Project SQL database. It also describes the SQL*Plus
script files located in ~/SQL.

The DDP database contains two tables:

				ddp_comm_tab

This small table contains one row for each commentary in the database. It
contains essential information about each comm. but does not contain
any comm. text. It does contain bibliographic information such as
the internal and display names of the comm., the comm. identifier,
publication information, the names of the editors, and its copyright
status. For details, see the SQL*Plus script create_ddp_comm_tab.sql,
which, as its name implies, is used to create the table.

There is a SQL index named ddp_text_comm_id_idx on the commentary
identifier column of this table. The index is created with the SQL*Plus
script create_ddp_text_comm_id_idx.sql.

				ddp_text_tab

This large table contains all the text of the poem and the commentaries.
There is one row for each tercet of the poem and for each piece of comm.
text. There are columns for the unique document identifier for the
piece of text, the comm. id, the cantica, canto, and line numbers,
and the language.  Another column contains the Unix relative path to
the source file for the piece of text. A CLOB (character large object)
column contains the actual text. For details, see the SQL*Plus script
create_ddp_text_tab.sql, which is used to create the table.

There is a SQL index named ddp_text_text_idx on the text column of this
table. It is created with script create_ddp_text_text_idx.sql. This index
must be recreated after each modification of the database, whether it
involves adding text or updating text. You would do this with SQL*Plus
by executing the script rebuild_ddp_text_text_idx.sql (or the symlink
reindex.sql).

Other SQL items and scripts:

In addition to the two database tables and their indices, there are
several auxilliary SQL items used by the database. These include
a stoplist (create_ddp_stoplist.sql) for specifying words not to be
indexed, a lexer (create_ddp_lexer.sql) used by Oracle in loading full
text, and storage allocation commands (create_ddp_lob_storage.sql)
created by our Oracle gurus to manage the storage used by the text.

The directory at ~/SQL contains SQL*Plus scripts to create and drop all
these tables, indices, and other items that make up the database. These
scripts are sufficient to delete and completely rebuild the SQL items that
comprise the database. They are also commented. They are the definitive
description of the SQL database.

There are two scripts - delete_text.sql and delete_desc.sql - which
delete one piece of text from the text table or one comm. row from the
comm. table.  Unlike the other scripts, these would not normally be
executed through command line invocation of SQL*Plus. Instead they are
executed when SQL*Plus is invoked from the Makefiles in the commentary
source directory. This happens when a piece of text or a description file
has been modified, e.g. fixing a typo. The makefile uses these scripts
to delete the old row from the database before loading the corrected one.

The ~/SQL directory also contains three SQL*Plus scripts that are
handy for routine examination and maintenance of the database. Scripts
show_comms.sql and show_text.sql respectively will retrieve and display
one row from the commentary description or text tables. Both scripts
require you to enter a WHERE phrase to specify the row you want to
find. The script show_size.sql generates a report of the storage
utilization of the database. This is most useful to Oracle gurus when
our storage is low or fragmented.

Written by Steve Campbell in January 2011.
