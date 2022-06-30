/*
 *	Create the DDP's SQL table for poem and commentary text.
 *
 * This SQL*Plus script creates the Dartmouth Dante Project SQL table for
 * holding pieces of commentary text and poem text. There is one row for
 * each tercet of the poem and for each piece of commentary text.
 *
 */
CREATE TABLE dante.ddp_text_tab (
   /*
    * doc_id is the unique identifier for a piece of commentary or poem
    * text. It is a text string defined as follows:
    *
    * cccccannlllt
    *
    * where:
    *
    * "ccccc" is the commentary id (ddp_comm_tab.comm_id) of the commentary
    * (or the poem) from which the text comes.
    *
    * "a" identifies the cantica to which the text applies, defined as follows:
    *	0 - applies to entire poem, a.k.a. comentum or intro.
    *	1 - Inferno
    *	2 - Purgatorio
    *	3 - Paradiso
    *
    * "nn" identifies the canto to which the text applies. A value of "00"
    * indicates a summary or proemio. Otherwise "nn" is two digits from "01"
    * to "34" identifying the canto.
    *
    * "lll" identifies the line number (or first line in a range) to which
    * the text applies. A value of "000" indicates a "proemio" or beginning
    * note covering the entire canto. A value greater than 200 indicates
    * a "conclusione" or ending note covering the entire canto.
    *
    * "t" is a tie-breaker number in case more than one piece of text refers
    * to the same line. For example one piece might apply to the range 
    * consisting of lines 34 through 48 while the next piece applies only
    * to line 34. The value of "lllt" for the two piece would be "0340" and
    * "0341" respectively.
    *
    * IMPORTANT: When search results are displayed to the user, they are first
    * sorted by increasing value of doc_id. So this value identifies the piece 
    * of text and determines where it appears in the results.
    */
   doc_id		CHAR(12),
   /*
    * comm_id identifies the commentary from which the text comes. This
    * is a foreign key that references the comm_id column of the 
    * ddp_comm_tab table.
    */
   comm_id		CHAR(5),
   /*
    * cantica_id identifies the cantica to which this piece refers. This
    * column is used for "line searches." It is a number from 0 to 3: 0 if
    * the text refers to the entire poem, 1 if it refers to Inferno, 2 for
    * Purgatorio, 3 for Paradiso.
    */
   cantica_id		NUMBER(1),
   /*
    * canto_id identifies the canto to which this piece refers. This column
    * is used for "line searches." It is a number from 0 to 34: 0 if the 
    * text refers to the entire cantica, 1 for canto 1, up to 34 for canto 34.
    */
   canto_id		NUMBER(2),
   /*
    * start_line identifies the line or beginning of a range of lines to which
    * the text refers. This column is used for "line searches." It is a number
    * from 0 to 134 (or whatever): 0 if the text refers to the entire canto,
    * otherwise the beginning (or only) line number.
    */
   start_line		NUMBER(3),
   /*
    * end_line identifies the line or end of a range of lines to which the
    * text refers. This column is used for "line searches." It is a number
    * from 0 to 134. It is 0 if the text refers to the entire canto; it is
    * equal to start_line if the text refers to a single line; it is the
    * ending line number of a range.
    */
   end_line		NUMBER(3),
   /*
    * text_language is a character string identifying the language of the
    * text. Its values are: "i" for Italian, "us" for English, "ltn" for
    * Latin. Oracle checks this column when it generates indices, so be
    * careful if you use other values. See Oracle's Globalization Support
    * Guide, Appendix A, Table A-1, for supported languages.
    */
   text_language	VARCHAR2(5),
   /*
    * source_path is the pathname of the source (*.e) file that contained
    * this piece of text. The path is relative to the main commentary
    * directory. For example if the absolute path name were /home/dante/C/benvenuto/inf/20.e,
    * then this variable would be benvenuto/inf/20.e. This column is useful
    * for deleting an entire file's worth of data from the database
    * prior to reloading that file.
    */
   source_path		VARCHAR(128),
   /*
    * text contains the commentary or poem text. Poem text is stored as a
    * 3-line tercet. Commentary text is stored as text.
    */
   text			CLOB,
   /* 
    * text_data_load_date is the date on which this database entry was loaded.
    * The load process should NOT load this column. Let Oracle supply it.
    */
   text_data_load_date  DATE DEFAULT sysdate,
   CONSTRAINT ddp_text_tab_pk
      PRIMARY KEY (doc_id)
   )
   TABLESPACE dante_data
   LOB (text) STORE AS ddp_lob_seg (TABLESPACE dante_lob)
;
GRANT SELECT ON dante.ddp_text_tab TO dante_user ;
