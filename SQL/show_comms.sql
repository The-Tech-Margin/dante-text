--
-- Display the entire contents of the commentary table, ddp_comm_tab.
--
SET VERIFY OFF
SET LINESIZE 185
SET PAGESIZE 50
SET NEWPAGE 0

COLUMN comm_id HEADING 'ID' FORMAT A5
COLUMN comm_name HEADING 'Name' FORMAT A12
COLUMN comm_author HEADING 'Author' FORMAT A26 WORD_WRAPPED
COLUMN comm_lang HEADING 'Lan' FORMAT A3
COLUMN comm_pub_year HEADING 'Pub. Year' FORMAT A18
COLUMN comm_biblio HEADING 'Bibliography' FORMAT A40 WORD_WRAPPED
COLUMN comm_editor HEADING 'Editor' FORMAT A28 WORD_WRAPPED
COLUMN comm_copyright HEADING 'C' FORMAT A1
COLUMN comm_data_entry HEADING 'Data Entry' FORMAT A25 WORD_WRAPPED
COLUMN comm_data_load_date HEADING 'Last Load'

BREAK ON comm_id SKIP PAGE

SELECT * FROM dante.ddp_comm_tab
	WHERE &where_phrase
	ORDER BY comm_id;
