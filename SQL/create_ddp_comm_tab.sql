/*
 *	Create the DDP's SQL table for Commentary Descriptions.
 *
 * This SQL*Plus script creates the Dartmouth Dante Project SQL table for
 * holding information about commentaries in the database. There is one row
 * for each commentary.
 *
 * The table created by this script does NOT contain the actual text of
 * the commentaries. The ddp_text_tab table does that.
 *
 */
CREATE TABLE ddp_comm_tab (
   /*
    * comm_id is the unique identifier for a commentary. It is a character
    * string consisting of the 4 digits of the publication year of the
    * commentary followed by a tie-breaker digit:
    *
    * yyyyt
    *
    * If the publication year is known exactly, we use that value. If there
    * is a range of years during which the commentary was published, use the
    * first year in the range.
    *
    * The tie-breaker distinguishes among commentaries which were published
    * in the same year. Its default value is 5 to allow numeric space for
    * future commentaries.
    *
    * Search results are displayed in the order of the comm_id of the
    * document, so the value of the tie-breaker digit is significant.
    *
    * Examples: For a commentary published in 1370, the comm_id might be
    * "13705". For a second commentary published in the same year but which
    * we want to display after the first one, the comm_id could be "13707".
    *
    * Search results are displayed in the order of the comm_id of the
    * document, so the value of the tie-breaker digit is significant.
    * This column is the primary key of the table.
    */
   comm_id		CHAR(5),
   /*
    * comm_name is the internal name of a commentary.
    * Its main use is as the name of the Unix directory which contains the
    * data files of the commentary. It is typically the name of the
    * commentary author, expressed in lower case.
    */
   comm_name		VARCHAR(64),
   /*
    * comm_author is the formal name of the commentary. It is suitable for
    * display on the results page. It is typically the author's name,
    * capitalized and blank-separated.
    */
   comm_author		VARCHAR(256),
   /*
    * comm_lang is the language in which the commentary is written.
    * It is one of the language abbreviation recognized by Oracle:
    * "ltn" for Latin, "i" for Italian, "us" for American.
    */
   comm_lang		VARCHAR(4),
   /*
    * comm_pub_year is the year in which the commentary was published.
    * The field is suitable for display with results. It may comtain
    * a single year such as "1846" or it may contain a range of years
    * or some other notation about the publication year such as
    * "1872-82[2nd ed 1900]".
    */
   comm_pub_year	VARCHAR(256),
   /*
    * comm_biblio is the bibliographic information about the commentary.
    * It typically lists the author, publication date, publication
    * location, editors, etc. Suitable for text display. Tagged with
    * <p>...</p>.
    */
   comm_biblio		VARCHAR(4000),
   /*
    * comm_editor is the name of the Dante Project editor for the commentary.
    */
   comm_editor		VARCHAR(256),
   /*
    * comm_copyright is set to "Y" if the commentary is copyrighted.
    * Otherwise it is set to "N". Tagged with <p>...</p>.
    */
   comm_copyright	CHAR(1),
   /*
    * comm_data_entry tells how the commentary text was entered. It may
    * say "KDEM" for texts that were scanned on the Kurtzweil scanner at
    * Kiewit back in the 1980's, or some similar designator. Tagged with
    * <p>...</p>.
    */
   comm_data_entry	VARCHAR2(4000),
   /*
    * comm_data_load_date is the date on which this database entry was loaded.
    * The load process should NOT load this column. Let Oracle supply it.
    */
   comm_data_load_date	DATE DEFAULT sysdate,
   CONSTRAINT ddp_comm_tab_pk
      PRIMARY KEY (comm_id)
   )
   TABLESPACE DANTE_DATA
;
GRANT SELECT ON ddp_comm_tab TO dante_user ;
