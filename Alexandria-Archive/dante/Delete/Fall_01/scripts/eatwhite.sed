#Eat large amounts of white space tabs
s/    *//g

#Eat white space after |
s/|   /   |/g
s/|  /  |/g
s/| / |/g

#Eat white space after ^
s/\^   /   \^/g
s/\^  /  \^/g
s/\^ / \^/g

#Eat white space before ~
s/   ~/~   /g
s/  ~/~  /g
s/ ~/~ /g
