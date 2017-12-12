s/-\~/\~-/g
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
s/ =\~/\~ =/g
s/\^\[/[^/g
s/\]\~/~]/g
s/\^</<^/g
s/>\~/~>/g
s/^        /	/g
s/^     /          /g
s/  / /g
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
s/  \([a-z]\)/ \1/g
s/  \^\([a-z]\)/ \^\1/g
s/  \([0-9]\)/ \1/g
s/ S\.  / S\. /g
s/cfr\.  /cfr\. /g
s/Cfr\.  /Cfr\. /g
s/ q\.  / q\. /g
s/ \$e / @e /g
s/  @\([a-z]\)/ @\1/g
s/  \$\([a-z]\)/ \$\1/g
s/\~ \^/ /g
s/\~\^//g
s/ - / -- /g
s/ -,/ --,/g
s/- \([0-9]\)/-\1/g
s/^	\([0-9]\)/	|\1/g
s/\~\./\.\~/g
s/\.\.\.  /\.\.\. /g
s/\.  \([IVXCMLD][IVXCMLD][IVXCMLD]*\)/. \1/g
s/\.  \([IVXCMLD][,.]\)/. \1/g
s/\.\~  \([IVXCMLD][IVXCMLD][IVXCMLD]*\)/.~ \1/g
s/\.\~  \([IVXCMLD][,.]\)/.~ \1/g
s/^	/.P\
/
