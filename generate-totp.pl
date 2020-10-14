#!/usr/bin/env perl
#
# generate-totp.pl
#
# Simple script for generating secret values for TOTP and printing
# them in different text formats and as QR code images.
#
# $Id$

use strict;
use warnings;
use Carp;
use English qw(-no_match_vars);
use MIME::Base32;
use Getopt::Long;
use Net::SSLeay;

my $generate_qrcode = 0;
my $accountname='test';
my $issuer='Radiator';
my $algorithm='SHA1';
my $hex_secret;
my $image_format = 'gif';  # Note: bmp may work without external Imager::File::.. modules
my $digits=6;
my $period=30;
my $qrcode_path='.';
my $noqrcode;
my @options = (
               'h' => \&usage,                    # Help, show usage
               'accountname=s' => \$accountname,  # OTP Account Name
               'issuer=s' => \$issuer,            # OTP Issuer
               'algorithm=s' => \$algorithm,      # Algorithm: SHA1, SHA256, or SHA512
               'digits=i' => \$digits,
               'period=i' => \$period,
               'hex_secret=s' => \$hex_secret,    # Hex encoded secret
               'image_format=s' => \$image_format,
               'qrcode_path=s' => \$qrcode_path,
               'noqrcode' => \$noqrcode,          # Don't generate QR code
               );

GetOptions(@options) || usage();

usage() if $algorithm ne 'SHA1' && $algorithm ne 'SHA256' && $algorithm ne 'SHA512';
usage() if $digits != 6 && $digits != 8;

unless (defined $noqrcode) {
    if (! eval { require Imager::QRCode; return 1; }) {
        carp "Warning: Could not load lib Imager::QRCode for generating QR code images: $EVAL_ERROR";
    }
    else {
        $generate_qrcode++;
    }

    if ($generate_qrcode) {
        my $format = uc($image_format);

        unless ($format eq 'BMP') {
	    my $class_name = "Imager::File::$format";
            my $image_lib = $class_name;
            $image_lib =~ s{::}{/}gs;
	    $image_lib .= '.pm';
            unless (eval { require $image_lib; return 1; }) {
                carp "Warning: Could not load lib $class_name for generating QR code images: $EVAL_ERROR";
                $generate_qrcode = 0;
            }
        }
    }
}

my $random_hexstring ='';
$random_hexstring = unpack('H*', random_octets(20)) if $algorithm eq 'SHA1' ;
$random_hexstring = unpack('H*', random_octets(32)) if $algorithm eq 'SHA256';
$random_hexstring = unpack('H*', random_octets(64)) if $algorithm eq 'SHA512';
$random_hexstring = $hex_secret if $hex_secret;
print "TOTP key to insert into Radiator database: $random_hexstring\n";

my $random_base32string = MIME::Base32::encode(pack("H*", $random_hexstring));

$random_base32string =~ s/(.{4})/$1 /sg;  # Add spaces
$random_base32string =~ s/ $//s;          # Remove trailing space

print "TOTP key in BASE32 for client: $random_base32string\n";

# This will die if the appropriate Imager::File::... module is not
# available. Try bmp if you do not wish to install additional modules.
#
if (!defined $noqrcode && $generate_qrcode) {
    my $img_file = "$qrcode_path/$issuer" . "_$accountname.$image_format";
    print "Writing QR code file $img_file\n";

    my $img = Imager::QRCode::plot_qrcode("otpauth://totp/$issuer:$accountname?secret=$random_base32string&issuer=$issuer&algorithm=$algorithm&digits=$digits&period=$period");
    $img->write(file => $img_file) or croak("Cannot write $img_file: " . $img->errstr);
}

sub random_octets
{
    my ($count) = @_;

    croak('Net::SSLeay::RAND_bytes() failed')
	unless Net::SSLeay::RAND_bytes(my $octets, $count);

    return $octets;
}

#####################################################################
sub usage
{
    print "usage: $PROGRAM_NAME [-accountname accountname] [-issuer issuer] [-algorithm SHA1|SHA256|SHA512]\n";
    print "       [-hex_secret string] [-digits 6|8] [-period period] [-image_format gif|bmp|jpeg|..]\n";
    print "       [-qrcode_path imagepath] [-noqrcode]\n";
    exit;
}
