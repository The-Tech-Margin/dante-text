s/->1/\>1-/g

s/%%ae/@@ae/g
s/%%oe/@@oe/g

s/ \~/\~ /g
s/:\~/\~:/g
s/:\([a-z]\)/: \1/g
s/,\~/\~,/g
s/;\~/\~;/g

s/;\([a-z]\)/; \1/g
s/\.\~/\~\./g
s/?\~/\~?/g
s/!\~/\~!/g
s/)\~/\~)/g
s/\^(/(\^/g
s/\~ \^/ /g
s/\. /\.  /g
s/\.> /\.>  /g
s/? /?  /g
s/?> /?>  /g
s/! /!  /g
s/!> /!>  /g
s/l' \([aeiouAEIOU]\)/l'\1/g
s/s' \([aeiouAEIOU]\)/s'\1/g
s/d' \([aeiouAEIOU]\)/d'\1/g
s/h' \([aeiouAEIOU]\)/h'\1/g
s/n' \([aeiouAEIOU]\)/n'\1/g

s/	<1/     <1/g
s/	<2/     <2/g

s/ S\.  / S\. /g
s/ \$e / @e /g
s/\~ \^/ /g
s/\~\^//g
s/\~\./\.\~/g
s/\.\.\.  /\.\.\. /g
s/^  \([A-Z]]\)/	\1/g
s/^	\([A-Z]\)/.P\
\1/
