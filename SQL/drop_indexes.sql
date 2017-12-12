--
-- Delete all indexes (other than the primary) on ddp_text_tab
--
-- Do this before loading or reloading large amounts of data.
--
DROP INDEX ddp_text_comm_id_idx;
DROP INDEX ddp_text_text_idx;
COMMIT;
