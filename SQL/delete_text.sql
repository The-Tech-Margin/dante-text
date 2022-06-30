--
-- Delete a row from the ddp_text_tab using the source_path field
--
-- This script gets invoked from the Makefile at C/Common.mk.
--
SET VERIFY OFF
DELETE FROM dante.ddp_text_tab WHERE source_path = '&1' ;
COMMIT ;
EXIT
