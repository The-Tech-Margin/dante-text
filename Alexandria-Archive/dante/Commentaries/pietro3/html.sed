s/<P>//g
s/<\/P>//g
s/<STRONG>/|/g
s/<\/STRONG>/~/g
s/<EM>/^/g
s/<\/EM>/~/g
/^<BR WP="BR1"><BR WP="BR2">$/d
s/<SUB>//g
s/<\/SUB>//g
s/<SUP>//g
s/<\/SUP>//g
s/<FONT[^>]*>//g
s/<\/FONT>//g
s/\~\^//g
