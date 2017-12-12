--
-- Retrieve and display DDP text documents.
--
SET VERIFY OFF
SET LINESIZE 132
SET PAGESIZE 50
SET NEWPAGE 0
SET LONG 20000

COLUMN text HEADING 'Text' FORMAT A60 WORD_WRAPPED
COLUMN doc_id HEADING 'Doc ID' FORMAT A13
COLUMN comm_id HEADING 'CommID' FORMAT A6
COLUMN cantica_id HEADING 'Ctca' FORMAT 9
COLUMN canto_id HEADING 'Cnto' FORMAT 99
COLUMN start_line HEADING 'Start' FORMAT 999
COLUMN end_line HEADING 'End' FORMAT 999
COLUMN text_language HEADING 'Lang' FORMAT A5
COLUMN load_date HEADING 'Loaded' FORMAT A16

BREAK	ON ROW SKIP PAGE

SELECT
	text, doc_id, comm_id, cantica_id, canto_id, start_line, end_line,
	text_language, TO_CHAR(text_data_load_date, 'hh24:mm dd-Mon-yy') load_date
	FROM dante.ddp_text_tab
	WHERE &where_phrase
	ORDER BY doc_id;
