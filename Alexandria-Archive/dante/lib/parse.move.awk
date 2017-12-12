BEGIN {	home = "/dante"; slash = "/"; andr = "andreoli"; scar = "scartazzini"; carr = "carroll"; camp = "campi"; long = "longfellow"; truc = "trucchi"; benn = "bennassuti"; inf = "inf"; purg = "purg"; para = "para"; print "mv " }

{print $1 " " }

/SCAR/ { auth = scar }
/CARR/ { auth = carr }
/CAMP/ { auth = camp }
/LONG/ { auth = long }
/TRUC/ { auth = truc }
/BENN/ { auth = benn }
/ANDR/ { auth = andr }

/PURGA/ { cantica = purg }
/INFER/ { cantica = inf }
/PARAD/ { cantica = para }

{print home slash auth slash cantica slash}
{ printf "%02d%2s\n", $NF, ".k" }
