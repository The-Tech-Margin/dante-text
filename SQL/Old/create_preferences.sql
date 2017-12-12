--
-- Create the SQL preferences needed to index the DDP
--
-- Refer to the Oracle Text Application Developer's Guide and
-- Oracle Text reference.
--
BEGIN
	/*
	 * Lexer (parser) for English
	 */
	ctx_ddl.create_preference('english_lexer','basic_lexer');
	ctx_ddl.set_attribute('english_lexer','index_themes','NO');
	ctx_ddl.set_attribute('english_lexer','index_text','YES');
	ctx_ddl.set_attribute('english_lexer','base_letter','YES');
	/*
	 * Lexer (parser) for Italian
	 */
	ctx_ddl.create_preference('italian_lexer','basic_lexer');
	ctx_ddl.set_attribute('italian_lexer','index_themes','NO');
	ctx_ddl.set_attribute('italian_lexer','index_text','YES');
	ctx_ddl.set_attribute('italian_lexer','base_letter','YES');
	/*
	 * Lexer (parser) for Latin (NOT USED. Latin treated like Italian.)
	 */
	/*
	ctx_ddl.create_preference('latin_lexer','basic_lexer');
	ctx_ddl.set_attribute('latin_lexer','index_themes','NO');
	ctx_ddl.set_attribute('latin_lexer','index_text','YES');
	ctx_ddl.set_attribute('latin_lexer','base_letter','YES');
	 */
	/*
	 * Create the multi-lexer (multi-language parser)
	 */
	ctx_ddl.create_preference('global_lexer','multi_lexer');
	/*
	 * Add the sub-lexers for the different languages. Italian
	 * is most common, so it is the default.
	 */
	ctx_ddl.add_sub_lexer('global_lexer','default','italian_lexer');
	ctx_ddl.add_sub_lexer('global_lexer','us','english_lexer');
	/*
	ctx_ddl.add_sub_lexer('global_lexer','latin','latin_lexer','ltn');
	 */
END;
/
