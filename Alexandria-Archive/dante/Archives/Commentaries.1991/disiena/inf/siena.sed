s/:\./:/g
s/((/</g
s/))/>/g
s/<</</g
s/>>/>/g
s/< /</g
s/ >/>/g
s/\~\~/\~/g
s/ \~/\~/g
s/\^ /\^/g
s/ - / -- /g
s/---/--/g
s/\([^ ]\)--\([^ ]\)/\1 -- \2/g
s/\([,;:?!)>]\)\~/\~\1/g
s/[  *]\([,\.;:?!\~]\)/\1/g
s/:\([^ ]\)/: \1/g
s/ --\~ /\~ -- /g
s/\^\([(<]\)/\1\^/g
s/\.\([!?]\)/\1/g

s/\.[  *]\([a-z0-9]\)/\. \1/g

s/\([lL]ib\.\)  /\1 /g
s/Inf\.  /Inf\. /g
s/Purg\.  /Purg\. /g
s/Parad\.  /Parad\. /g
s/Giamb\.  Stor\.  Paol\.  Oros\.  /Giamb\. Stor\. Paol\. Oros\. /g
s/Ecl\.  /Ecl\. /g
s/ S\.  / S\. /g
s/ SS\.  / SS\. /g
s/ st\.  / st\. /g
s/Virg\.  /Virg\. /g

