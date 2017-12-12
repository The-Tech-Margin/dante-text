--
-- Delete all indices and all data from both DDP tables
--
-- You would normally do this in conjunction with a 'make TARGET=clean'
-- in ~dante/C. Presumably this would be followed by a 'make' in the same
-- location.
--
SET ECHO ON
DROP INDEX ddp_text_comm_id_idx;
DROP INDEX ddp_text_text_idx;
TRUNCATE TABLE ddp_text_tab;
TRUNCATE TABLE ddp_comm_tab;
COMMIT;
