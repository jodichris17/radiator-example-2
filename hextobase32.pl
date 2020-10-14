#!/usr/bin/perl
#
# hextobase32.pl
#
# Convert hex string to Base32 and back. Used, for example, for
# converting TOTP and HOTP hex formatted seed values to Base32 format
# that is often used with authenticator applications.
#
# Hex input 1111111111111111111111111111111111111111 results in Base32
# CEIR CEIR CEIR CEIR CEIR CEIR CEIR CEIR
#
use strict;
use warnings;
use MIME::Base32;

unless (defined $ARGV[0] &&
	($ARGV[0] =~ m/^[a-f0-9]+$/i) ||
	($ARGV[0] eq '-d' && defined $ARGV[1] && $ARGV[1] =~ m/^[a-z2-7= ]+$/i))
{
    print "usage: $0 hexstring\n";
    print "       $0 -d base32string\n";
    print "\n";
    print "Spaces in base32string are ignored but need to be quoted on command line.\n";

    exit(1);
}

# Decode Base32 to hex
if ($ARGV[0] eq '-d')
{
    my $base32 = $ARGV[1];
    $base32 =~ s/ //g; # Remove spaces
    my $hex = unpack('H*', MIME::Base32::decode_rfc3548($base32));
    print $hex . "\n";
    exit(0);
}

# Encode hex to Base32
my $hex = $ARGV[0];
my $base32 = MIME::Base32::encode_rfc3548(pack("H*", $hex));

$base32 =~ s/(.{4})/$1 /g;  # Add spaces
$base32 =~ s/ $//;          # Remove trailing space

print $base32 . "\n";
