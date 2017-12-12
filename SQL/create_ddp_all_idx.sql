/*
 *	Create all SQL indices for the Dartmouth Dante Project.
 *	You would typically do this immediately after doing
 *	a 'make' to load the entire database.
 */
@create_ddp_text_comm_id_idx
@create_ddp_text_text_idx
commit;
