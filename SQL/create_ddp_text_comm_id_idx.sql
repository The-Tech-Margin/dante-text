/*
 *      Create the Dartmouth Dante Project SQL index for
 *	the comm_id column of the ddp_text_tab table.
 */
CREATE INDEX ddp_text_comm_id_idx
	ON dante.ddp_text_tab(comm_id)
	TABLESPACE dante_data
	;
