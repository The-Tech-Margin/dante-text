/*
 * Delete the DDP lob_storage preference.
 */

BEGIN
	ctx_ddl.drop_preference('ddp_lob_storage');
END;
/
