/*
 * A file of SQL commands to test how stoplists work.
 */
create table stoptest (
  id	  number constraint pk_text primary key,
  text  varchar2(50),
  lang  varchar2(15)
);

/*
 * Insert some data
*/
  insert into stoptest values (1,'The cat sat die on the mat','us');
  insert into stoptest values (2,'The cats sat on the mat','us');
  insert into stoptest values (3,'die Katze heisst Müller','d');
  insert into stoptest values (4,'die Katzen sassen auf der Matte','d');
  insert into stoptest values (5,'le chat sest reposé sur la natte','f');
  insert into stoptest values (6,'les chats se sont reposés sur la natte','f');
  insert into stoptest values (7,'dunque allora correva il 1300, poiché','i');
  insert into stoptest values (8,'Et hic sequituropinionem Ovidii','lat');
  commit;

/*
 * The next step is to configure the lexer
 */

begin
  ctx_ddl.create_preference('test_lexer','basic_lexer');
  ctx_ddl.set_attribute('test_lexer','index_themes','no');
  ctx_ddl.set_attribute('test_lexer','index_text','yes');
  ctx_ddl.set_attribute('test_lexer','base_letter','yes');
end;
/

/*
 * Create a multi-language stoplist
 */
begin
  ctx_ddl.create_stoplist('teststop', 'MULTI_STOPLIST');
  ctx_ddl.add_stopword('teststop', 'the', 'us');
  ctx_ddl.add_stopword('teststop', 'il', 'i');
  ctx_ddl.add_stopword('teststop', 'die', 'd');
  ctx_ddl.add_stopword('teststop', 'hic', 'ALL');
end;
/
/*
 *  Now we can create the Oracle text index, using the DDP lexer preference.
 *  We will also need to specify the name of the language column:
 */
   create index stoptext_ind on stoptest(text) 
    indextype is ctxsys.context
    parameters('lexer test_lexer
		stoplist teststop
                language column lang');

