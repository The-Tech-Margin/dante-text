--
-- Delete the SQL preferences needed to index the DDP
--
-- Refer to the Oracle Text Application Developer's Guide and
-- Oracle Text reference.
--
BEGIN
	ctx_ddl.drop_preference('global_lexer');
	ctx_ddl.drop_preference('english_lexer');
	ctx_ddl.drop_preference('italian_lexer');
	/*
	ctx_ddl.drop_preference('latin_lexer');
	 */
END;
/
