--
-- Delete a row from the ddp_comm_tab
--
-- This script gets invoked from the Makefile at C/Common.mk
--
SET VERIFY OFF
DELETE FROM ddp_comm_tab WHERE comm_id = &1 ;
EXIT
