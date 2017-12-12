--
-- Display the size of tables and indices
--
SET FEEDBACK OFF
SET VERIFY OFF
SET LINESIZE 85
SET PAGESIZE 60

COLUMN tablespace_name HEADING 'Table Space' FORMAT A15
COLUMN segment_type HEADING 'Type' FORMAT A15
COLUMN segment_name HEADING 'Name' FORMAT A30
COLUMN bytes HEADING 'Bytes' FORMAT 999,999,999
COLUMN extents HEADING 'Extents' FORMAT 999

BREAK ON REPORT ON tablespace_name SKIP 1 NODUP;

CLEAR COMPUTES
COMPUTE SUM LABEL 'Total' OF bytes on tablespace_name
COMPUTE SUM LABEL 'Grand Total' OF bytes on REPORT

SELECT tablespace_name, segment_type, segment_name, bytes, extents
	FROM user_segments
	ORDER BY tablespace_name, segment_type, segment_name;
