#!/bin/sh
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express oqr
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is historgram-diff.sh, released Dec 8, 2000.
#
# The Initial Developer of the Original Code is Netscape
# Communications Corporation.  Portions created by Netscape are
# Copyright (C) 2000 Netscape Communications Corporation. All
# Rights Reserved.
#
# Contributor(s):
#    Chris Waterson <waterson@netscape.com>
#
# This shell script takes two `object histograms' produced using
# `histogram.pl' and prints the delta, sorted such that the objects
# that increased the most in raw memory usage are displayed at the
# top.

BASE=$1
INCR=$2

# Sort the base and incremental files so that we can `join' them on
# the type name
sort $BASE > /tmp/$$.left
sort $INCR > /tmp/$$.right

# Do the join. The first `awk' script computes the difference between
# the base and the incremental files. The second `awk' script computes
# a `TOTAL' row. Then, we sort by the larges delta in bytes.
join /tmp/$$.left /tmp/$$.right |\
    awk '{ print $1, $2, $3, $4, $5, $4 - $2, $5 - $3; }' |\
    awk '{ tobj1 += $2; tbytes1 += $3; tobj2 += $4; tbytes2 += $5; tdobj += $6; tdbytes += $7; print $0; } END { print "TOTAL", tobj1, tbytes1, tobj2, tbytes2, tdobj, tdbytes; }' |\
    sort -nr +6 > /tmp/$$.sorted

rm -f /tmp/$$.left /tmp/$$.right

# Pretty-print, including percentages
cat <<EOF > /tmp/$$.awk
BEGIN {
  print "                        ---- Base ----   ---- Incr ----   ----- Difference ----";
  print "Type                    Count    Bytes   Count    Bytes   Count    Bytes %Total";
  }
\$1 == "TOTAL" {
  tbytes = \$7;
  }
NR <= 20 {
  printf "%-22s %6d %8d  %6d %8d  %6d %8d %6.2lf\n", \$1, \$2, \$3, \$4, \$5, \$6, \$7, 100.0 * \$7 / tbytes;
  }
NR > 20 {
  oobjs1 += \$2;  obytes1 += \$3;
  oobjs2 += \$4;  obytes2 += \$5;
  odobjs += \$6;  odbytes += \$7;
  }
END {
  printf "%-22s %6d %8d  %6d %8d  %6d %8d %6.2lf\n", "OTHER", oobjs1, obytes1, oobjs2, obytes2, odobjs, odbytes, odbytes * 100.0 / tbytes;
  }
EOF

# Now pretty print the file, and spit it out on stdout.
awk -f /tmp/$$.awk /tmp/$$.sorted

rm -f /tmp/$$.awk
