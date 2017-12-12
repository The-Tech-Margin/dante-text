# Expand some bibliographic abbreviations used in the Chiavacci commentary.
# The patterns are sorted into longest first to avoid partial matches.
# Usage: sed -f ~/Sed/expandabbr.sed -i -s *.e
#
s/Du Cange/& [C. Du Cange, ^Glossarium mediae et infimae Latinitatis~, Paris 1883-1887]/
s/CLPIO/& [^Concordanze della lingua poetica italiana delle origini~, a c. di d'A.S. Avalle, Milano-Napoli 1992]/
s/BISI/& [<Bullettino dell'Istituto Storico Italiano>]/
{
s/BSDI/& [<Bullettino della Societ@a Dantesca Italiana>]/
t
}
s/GSLI/& [<Giornale storico della letteratura italiana>]/
{
s/GDLI/& [^Grande dizionario della lingua italiana~, a c. di S. Battaglia, Torino 1961-2002]/
t
}
{
s/RIS2/& [L.A. Muratori, ^Rerum Italicarum Scriptores~ (nuova ed.), Citt@a di Castello-Bologna 1900 sgg.]/
t
}
s/SPCT/& [<Studi e problemi di critica testuale>]/
{
s/DBI/& [^Dizionario biografico degli italiani~, Roma 1960-]/
t
}
s/DDJ/& [<Deutsches Dante Jahrbuch>]/
{
s/DEI/& [C. Battisti-G. Alessio, ^Dizionario etimologico italiano~, Firenze 1950-1957]/
t
}
{
s/LCD/& [^Letture della Casa di Dante in Roma~, Roma 1977-1989]/
t
}
{
s/LDI/& [^Lectura Dantis internazionale~, a c. di V. Vettori, Milano 1963-1970]/
t
}
{
s/LDM/& [^Lectura Dantis Modenese~ 1984-1986]/
t
}
{
s/LDN/& [^Lectura Dantis Neapolitana~, Napoli 1980-]/
t
}
{
s/LDP/& [^Lectura Dantis Pompeiana~, Pompei 1983 e 1985]/
t
}
{
s/LDR/& [^Lectura Dantis Romana~, Torino 1959-1965]/
t
}
{
s/LDS/& [^Lectura Dantis Scaligera~, Firenze 1967-1968]/
t
}
{
s/NLD/& [^Nuove letture dantesche~, Firenze 1966-1976]/
t
}
{
s/PLD/& [^La poesia lirica del Duecento~, a c. di C. Salinari, Torino 1968]/
t
}
s/LEI/& [^Lessico etimologico italiano~, a c. di M. Pfister, Wiesbaden 1979 sgg.]/
{
s/MGH/& [^Monumenta Germaniae Historica~, Berlin 1826-]/
t
}
s/MGP/& [^Monumenta Historiae Patriae Scriptores~, Torino 1840-1844]/
{
s/NTF/& [^Nuovi testi fiorentini del Dugento~, a c. di A. Castellani, Firenze 1952]/
t
}
s/PMT/& [^Poeti minori del Trecento~, a c. di N. Sapegno, Milano-Napoli 1964]/
s/RAL/& [<Atti dell'Accademia Nazionale dei Lincei. Rendiconti. Classe di scienze morali, storiche e filologiche>]/
s/RCD/& [^Rimatori comico-realistici del Due e Trecento~, a c. di M. Marti, Torino 1956]/
{
s/REI/& [<Revue des $etudes italiennes>]/
t
}
s/REW/& [W. Meyer L,ubke, ^Romanisches etimologisches W,orterbuch~, Heidelberg 1935]/
s/RIS/& [L.A. Muratori, ^Rerum Italicarum Scriptores~, Milano 1723-1751]/
s/RVF/& [^Rerum vulgarium fragmenta~: cfr. Petrarca, ^Canzoniere~, a c. di G. Contini, Torino 1964]/
s/TLL/& [^Thesaurus linguae latinae~, Leipzig 1900 sgg.]/
s/\^S\.T\.\~/& [cfr. Tommaso d'Aquino, ^Summa theologiae~, Roma 1888-1906]/
s/DB/& [^Dictionnaire de la Bible~, a c. di F. Vigouroux, Paris 1895-1912]/
s/DS/& [<Dante Studies>]/
s/ED/& [^Enciclopedia Dantesca~, Roma 1970-1976]/
s/EI/& [^Enciclopedia Italiana di scienze, lettere ed arti~, Roma 1929-1939]/
s/FC/& [<Filologia e Critica>]/
s/FF/& [^Fontes francescani~, a c. di E. Menest@o e S. Brufani, Assisi 1995]/
s/GD/& [<Giornale Dantesco>]/
s/LC/& [^Letture classensi~, Ravenna 1966 sgg.]/
s/LD/& [^Letture Dantesche~, a c. di G. Getto, Firenze 1955-1961]/
s/MW/& [^Mittelateinisches W,orterbuch~, M,unchen 1967-]/
s/NA/& [<Neues Archiv>]/
s/PD/& [^Poeti del Duecento~, a c. di G. Contini, Milano-Napoli 1960]/
s/PG/& [^Patrologia Graeca~, a c. di J.-P. Migne, Paris 1857-1876]/
s/PL/& [^Patrologia Latina~, a c. di J.-P. Migne, Paris 1844-1865]/
s/SD/& [<Studi Danteschi>]/
s/TB/& [N. Tommaseo-B. Bellini, ^Dizionario della lingua italiana~, Torino 1865-1879]/
s/TF/& [^Testi fiorentini del Dugento e dei primi del Trecento~, a c. di A. Schiaffini, Firenze 1926]/
