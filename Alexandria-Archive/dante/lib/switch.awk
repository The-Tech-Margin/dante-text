# awk program to switch the find and replace fields in sed scripts
BEGIN { FS = "/" ; OFS = "/" }
{print $1 "/" $3 "/" $2 "/" $4}
