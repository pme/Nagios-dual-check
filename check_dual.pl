#!/usr/bin/perl
# nagios: -epn
#
# check_dual.pl - runs the same check for two IP addresses
# Copyright (C) 2012 Peter Meszaros <hauptadler@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use Getopt::Std;

our($opt_H, $opt_c, $opt_1, $opt_t, $opt_h);

my $version = '0.1';

use constant {
  OK       => 0, # Luckily the Nagios status values are numbered from 0 to 3.
  WARNING  => 1, # The following code is heavily based on this assumption.
  CRITICAL => 2,
  UNKNOWN  => 3,
};

my @statestr = qw(OK WARNING CRITICAL UNKNOWN);

my ($ret, $retstr);

             # Truth table for the 2of2 checks
             # OK       WARNING   CRITICAL  UNKOWN
my @tt2o2 = ([ OK,      WARNING,  WARNING,  WARNING  ],  # OK 
             [ WARNING, WARNING,  CRITICAL, CRITICAL ],  # WARNING
			 		   [ WARNING, CRITICAL, CRITICAL, CRITICAL ],  # CRITICAL
			 		   [ WARNING, CRITICAL, CRITICAL, UNKNOWN  ]); # UNKNOWN

             # Truth table for the 1of2 checks
             # OK       WARNING   CRITICAL  UNKOWN
my @tt1o2 = ([ OK,      OK,       OK,       OK       ],  # OK 
             [ OK,      WARNING,  WARNING,  WARNING  ],  # WARNING
			 		   [ OK,      WARNING,  CRITICAL, CRITICAL ],  # CRITICAL
			 		   [ OK,      WARNING,  CRITICAL, UNKNOWN  ]); # UNKNOWN

getopts('H:c:1th'); 

if (!defined($opt_H) || !defined($opt_c)) {
	usage();
	exit UNKNOWN;
}

my @ips = split(',', $opt_H);

my @crets;
foreach (@ips) {
	print "$opt_c -H $_ @ARGV\n" if $opt_t;
	chomp(my $r = `$opt_c -H $_ @ARGV`);
	push(@crets, $? >> 8);
	$retstr .= $r . ' ';
}

$ret = $opt_1 ? $tt1o2[$crets[0]][$crets[1]] : $tt2o2[$crets[0]][$crets[1]];

print "$statestr[$ret] - $retstr\n";

exit $ret;

#-----------------------------------------------------------------------------

sub usage
{
	print <<EOD
check_dual.pl - runs the same check for two IP addresses
Version: $version, Copyright (C) 2012 Peter Meszaros <hauptadler\@gmail.com>

Usage: $0 -H ip1,ip2 [-1] [-t] [-h] -c command -- -a p1 -b p2

\t-H ipaddresses separated by comma
\t-1 one of two mode
\t-t trace
\t-c check to execute (the very first command line switch must be preceeded with '--')
\t-h prints this message
EOD
}

