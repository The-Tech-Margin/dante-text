s/' \([aeiouAEIOU]\)/'\1/g
s/' \([@\$#,][aeiouAEIOU]\)/'\1/g
s/' \^\([aeijouAEIJOU]\)/'\^\1/g
s/' \^\([@\$#,][aeijouAEIJOU]\)/'\^\1/g

s/'\([bcdfghklmnpqrstvwxzBCDFGHKLMNPQRSTVWXZ]\)/' \1/g

s/\([^  *]\)--/\1 --/g

s/\([\.?!]\)\~/\~\1/g
s/\.\([a-zA-Z@\$#]\)/\. \1/g
s/\([\.?!]\)  */\1 /g
s/\([\.?!]\) /\1  /g
s/\([\.?!]\)  \([a-z]\)/\1 \2/g
s/\([\.?!]\)  \([\^@\$#,|][a-z]\)/\1 \2/g

s/\.  \([0-9]\)/\. \1/g
s/\.  \([IXVLC][IXVLC]\)/\. \1/g

s/\([^A-Z][A-Z]\)\.  /\1\. /g
s/Paol\.  /Paol\. /g
s/Brun\.  Lat/Brun\. Lat/g
s/Oros\.  /Oros\. /g
s/Rettor\.  /Rettor\. /g
s/Quadr\.  /Quadr\. /g
s/Dittam\.  /Dittam\. /g
s/Giamb\.  /Giamb\. /g
s/Cic\.  /Cic\. /g
s/Somn\.  /Somn. /g
s/Scip\.  /Scip\. /g
s/Provenz\.  /Provenz\. /g
s/princ\.  /princ\. /g
s/vit\.  /vit\. /g
s/Giord\.  /Giord\. /g
s/Franc\.  /Franc\. /g
s/Pred\.  /Pred\. /g
s/Din\.  /Din\. /g
s/Comp\.  /Comp\. /g
s/Nann\.  /Nann\. /g
s/Jul\.  /Jul\. /g
s/Ces\.  /Ces\. /g
s/crit\.  /crit\. /g
s/Tull\.  /Tull\. /g
s/Ibid\.  /Ibid\. /g
s/Vill\.  /Vill\. /g
s/Vit\.  Nuova/Vit\. Nuova/g
s/\([Ll]\)ib\.  /\1ib\. /g
s/Sallust\.  /Sallust\. /g
s/Cat\.  /Cat\. /g
s/Id\.  /Id\. /g
s/\([Ii]\)t\.  /\1t\. /g
s/Tratt\.  /Tratt\. /g
s/\([lL]\)ett\.  /\1ett\. /g
s/\([nN]\)ot\.  /\1ot\. /g
s/Vegez\.  /Vegez\. /g
s/Bocc\.  /Bocc\. /g
s/Murat\.  /Murat\. /g
s/Nov\.  /Nov\. /g
s/Parad\.  /Parad\. /g
s/Purgat\.  /Purgat\. /g
s/Inf\.  /Inf\. /g
s/Par\.  /Par\. /g
s/Tom\.  /Tom\. /g
s/Teor\.  /Teor\. /g
s/Svet\.  /Svet\. /g
s/Calig\.  /Calig\. /g
s/Ecl\.  /Ecl\. /g
s/Georg\.  /Georg\. /g
s/Manual\.  /Manual\. /g
s/\([Cc]\)ap\.  /\1ap\. /g
s/En\.  /En\. /g
s/Od\.  /Od\. /g
s/Orl\.  /Orl\. /g
s/Fur\.  /Fur\. /g
s/Sat\.  /Sat\. /g
s/sat\.  /sat\. /g
s/Salm\.  /Salm\. /g
s/Is\.  /Is\. /g
s/pag.  /pag\. /g
s/Verb\.  /Verb\. /g
s/Virg\.  /Virg\. /g
s/Tr\.  /Tr\. /g
s/Morg\.  /Morg\. /g
s/Stor\.  /Stor\. /g
s/Giosaf\.  /Giosaf\. /g
s/Emm\.  R/Emm\. R/g
s/Nap\.  /Nap\. /g
s/\([cC]\)od\.  /\1od\. /g
s/Vatic\.  /Vatic\. /g
s/Casin\.  /Casin\. /g
s/Cassin\.  /Cassin\. /g
s/Guitt\.  /Guitt\. /g
s/rom\.  /rom\. /g
s/Corn\.  /Corn\. /g
s/Fm\.  /Fm\. /g
s/Viridar\.  /Viridar\. /g
s/Fr\.  /Fr\. /g
s/Fir\.  /Fir\. /g
s/ant\.  /ant\. /g
s/\([Vv]\)ol\.  /\1ol\. /g
s/' l /'l /g
s/ i ' / i' /g
s/' \([bcdfghklmnpqrstvwxz][bcdfghklmnpqrstvwxz]\)/ '\1/g

s/( /(/g
s/ )/)/g
s/< /</g
s/ >/>/g

s/\([?,)\]:;!\}>-]\)\~/\~\1/g
s/\~\./\.\~/g
