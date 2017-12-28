/*
 *      Rebuild the Dartmouth Dante Project SQL index for
 *	the text column of the ddp_text_tab table. You would
 *	typically do this after replacing one or more rows
 *	of the database, for example by doing a 'make' in
 *	one of the commentary subdirectories. The operation
 *	takes about 5 minutes, during which text searches will
 *	find no hits.
 */
ALTER INDEX ddp_text_text_idx
	REBUILD
	;
EXIT
