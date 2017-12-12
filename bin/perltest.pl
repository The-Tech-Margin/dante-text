#!/usr/bin/perl -w
#
# This script reproduces a bug involving UTF-8 and regular expressions.
# This script will cause a Perl panic when given "/asdffa/asfddsa/asfas.xx"
# as input. See Bugzilla bug 90422 at https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=90422.
#
use File::Basename;
while (<STDIN>) {
   chop;
   $bname = basename ($_);
   ($dname = $_) =~ s/\/$bname$//;
   print "d=$dname b=$bname\n";
}
