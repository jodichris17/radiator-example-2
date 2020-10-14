#!/usr/bin/env perl
#
# nthash.pl
#
# Simple script to generate the {nthash} version of a password.
#
# $Id$

use strict;
use warnings;
use English qw(-no_match_vars);
use Carp;
use Digest::MD4;

die "usage: $PROGRAM_NAME password\n" unless defined $ARGV[0];

# Same as NtPasswordHash(ASCIItoUnicode($ARGV[0]))
my $result = join('', map {($_, "\0")} split(m//s, $ARGV[0]));
$result = Digest::MD4::md4($result);

$result = uc(unpack('H*', $result));

print "{nthash}$result\n";
