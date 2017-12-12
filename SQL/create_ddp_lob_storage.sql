/*
 *	The preference named 'ddp_lob_storage' is used
 *	on the advice of Dan Longnecker to control which
 *	Oracle tablespace gets used to hold the index.
 */
BEGIN
   ctx_ddl.create_preference('ddp_lob_storage','basic_storage');
   ctx_ddl.set_attribute('ddp_lob_storage','i_table_clause','tablespace dante_lob');
   ctx_ddl.set_attribute('ddp_lob_storage','k_table_clause','tablespace dante_lob');
   ctx_ddl.set_attribute('ddp_lob_storage','r_table_clause','tablespace dante_lob');
   ctx_ddl.set_attribute('ddp_lob_storage','n_table_clause','tablespace dante_lob');
   ctx_ddl.set_attribute('ddp_lob_storage','i_index_clause','tablespace dante_lob');
   ctx_ddl.set_attribute('ddp_lob_storage','p_table_clause','tablespace dante_lob');
END;
/
