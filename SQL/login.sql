DEFINE _EDITOR = "vim"
SET TERMOUT OFF
COLUMN dbname NEW_VALUE prompt_dbname
SELECT LOWER(SUBSTR(global_name,1,INSTR(global_name,'.')-1)) dbname FROM global_name;
SET SQLPROMPT "&&prompt_dbname> "
SET TERMOUT ON
