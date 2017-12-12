/*
 * Define the lexer used for the DDP. See the Oracle Text Reference manual.
 */

begin
  ctx_ddl.create_preference('ddp_lexer','basic_lexer');
  ctx_ddl.set_attribute('ddp_lexer','index_themes','no');
  ctx_ddl.set_attribute('ddp_lexer','index_text','yes');
  ctx_ddl.set_attribute('ddp_lexer','base_letter','yes');
end;
/
