/*
 * Create a custom stopword list (stoplist) for the Dartmouth Dante Project.
 *
 * This is what Oracle calls a multi-language stoplist.
 * See Oracle Text Reference for details.
 */

BEGIN
	/*
	 * Create the stoplist
	 */
	ctx_ddl.create_stoplist('ddp_stoplist', 'MULTI_STOPLIST');
	/*
	 * Add English words to the list. These are from the Oracle "supplied stoplist" for English.
	 */
	ctx_ddl.add_stopword('ddp_stoplist', 'about', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'after', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'also', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'an', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'any', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'and', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'are', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'as', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'be', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'because', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'been', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'but', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'by', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'can', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'could', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'for', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'from', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'had', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'has', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'have', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'he', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'her', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'his', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'if', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'into', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'is', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'it', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'its', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'last', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'more', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'most', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'mr', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'mrs', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'ms', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'no', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'not', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'only', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'of', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'on', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'one', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'or', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'other', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'out', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'over', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 's', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'so', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'says', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'she', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'some', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'such', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'than', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'that', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'the', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'their', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'there', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'they', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'this', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'to', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'was', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'we', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'were', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'when', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'which', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'who', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'will', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'with', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'would', 'us');
	ctx_ddl.add_stopword('ddp_stoplist', 'up', 'us');
	/*
	 * Add Italian words to the list. These are from the DDP BRS list and the Oracle Italian list.
	 * We mark these as stopwords for ALL languages since they appear frequently when the poem
	 * is quoted in commentaries written in English or Latin.
	 */
	ctx_ddl.add_stopword('ddp_stoplist', 'a', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ad', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'agli', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ai', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'al', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'all', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'alle', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ce', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'che', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'chi', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ci', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'col', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'con', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'da', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'dal', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'del', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'dell', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'della', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'delle', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'dello', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'di', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'e', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'i', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'il', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'in', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'l', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'la', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'le', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'lo', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ma', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'nel', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'nella', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'nelle', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'o', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'per', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'se', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'si', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'un', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'una', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'uno', 'ALL');
	/*
	 * Add Latin words. Since Oracle does not support Latin, mark these words as applying
	 * to ALL languages. This seems harmless and gets the job done.
	 */
	ctx_ddl.add_stopword('ddp_stoplist', 'ab', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ac', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'at', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'de', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'et', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'etc', 'ALL');
	ctx_ddl.add_stopword('ddp_stoplist', 'ex', 'ALL');
END;
/
