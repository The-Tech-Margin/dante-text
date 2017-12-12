/*
 * Undo everything done in stoplisttest.sql
 */

drop table stoptest;

BEGIN
	ctx_ddl.drop_preference('test_lexer');
	ctx_ddl.drop_stoplist('teststop');
END;
/
