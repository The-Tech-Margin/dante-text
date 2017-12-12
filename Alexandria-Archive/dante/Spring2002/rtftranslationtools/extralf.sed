#remove canto titles from beginning of documents
/|[A-Z]\+ CANTO [0-9A-Z]\+~/{
$!N
$!N
s/|[A-Z]\+ CANTO [0-9A-Z]\+~\n\n\(.*\)/\1/g
}

#remove extra carriage returns after canto numbers
/	|[0-9-]\+\.~/{
$!N
s/\(	|[0-9-]\+\.~\)\n\(.*\)/\1 \2/g
}

