/*
 * Delete the DDP lexer
 */

BEGIN
	ctx_ddl.drop_preference('ddp_lexer');
END;
/
