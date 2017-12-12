/*
 *      Create the Dartmouth Dante Project SQL index for
 *	the text column of the ddp_text_tab table.
 */
CREATE INDEX ddp_text_text_idx
	ON ddp_text_tab(text)
	INDEXTYPE IS CTXSYS.CONTEXT
	PARAMETERS ('LEXER ddp_lexer
		     STOPLIST ddp_stoplist
		     LANGUAGE COLUMN text_language
		     FILTER ctxsys.null_filter
		     SECTION GROUP ctxsys.html_section_group')
	;
