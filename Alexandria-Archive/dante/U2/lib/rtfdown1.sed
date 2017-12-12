s/>/\\'c8/g
s/</\\'c7/g
s/@@Oe/\\'ce/g
s/@@oe/\\'cf/g
s/@@Ae/\\'ae/g
s/@@ae/\\'be/g
s/,u/\\'9f/g
s/,U/\\'86/g
s/,o/\\'9a/g
s/,O/\\'85/g
s/,i/\\'95/g
s/,I/\\'acI/g
s/,e/\\'91/g
s/,E/\\'acE/g
s/,a/\\'8a/g
s/,A/\\'80/g
s/#u/\\'9e/g
s/#U/^U/g
s/#o/\\'99/g
s/#O/^O/g
s/#i/\\'94/g
s/#I/^I/g
s/#e/\\'90/g
s/#E/^E/g
s/#a/\\'89/g
s/#A/^A/g
s/$c/\\'8d/g
s/$C/\\'82/g
s/$q/\\'abq/g
s/$Q/\\'abQ/g
s/$u/\\'9c/g
s/$U/\\'abU/g
s/$o/\\'97/g
s/$O/\\'abO/g
s/$i/\\'92/g
s/$I/\\'abI/g
s/$e/\\'8e/g
s/$E/\\'83/g
s/$a/\\'87/g
s/$A/\\'abA/g
s/@q/`q/g
s/@Q/`Q/g
s/@u/\\'9d/g
s/@U/`U/g
s/@o/\\'98/g
s/@O/`O/g
s/@i/\\'93/g
s/@I/`I/g
s/@e/\\'8f/g
s/@E/`E/g
s/@a/\\'88/g
s/@A/\\'cb/g
s/\([^ ]\)+/\1{\\up6 /g
s/~/}/g
s/\^/{\\ul /g
s/|/{\\b /g
s/^[ 	]*//

/^$/i\
\\f200 {\\par}

/^\.P$/c\
\\s3\\fi720 {\\f200

/^\.U$/c\
\\s2 \\f200

/^\.X$/c\
\\s6\\fi-360\\li360 \\f200

/^\.T$/c\
\\s3\\fi720\\li360\\ri360 \\f200

/^\.I$/c\
\\s4\\fi360 \\f200

/^$/d
