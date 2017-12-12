/*
 *      Create the Dartmouth Dante Project SQL index for
 *	the text column of the ddp_text_tab table.
 *
 *	This is the big full-text index over the pieces of
 *	commentary text.
 *
 *	Be sure to run create_ddp_lob_storage.sql before
 *	running this script.
 */

CREATE INDEX ddp_text_text_idx
	ON ddp_text_tab(text)
	INDEXTYPE IS CTXSYS.CONTEXT
	PARAMETERS ('LEXER ddp_lexer
                     STORAGE ddp_lob_storage
		     STOPLIST ddp_stoplist
		     LANGUAGE COLUMN text_language
		     FILTER ctxsys.null_filter
		     SECTION GROUP ctxsys.html_section_group')
	;
