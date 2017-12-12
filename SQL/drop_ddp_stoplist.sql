/*
 * Delete the DDP stoplist
 */

BEGIN
	ctx_ddl.drop_stoplist('ddp_stoplist');
END;
/
