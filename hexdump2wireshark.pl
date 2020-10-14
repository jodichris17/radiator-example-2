#!/usr/bin/perl
#
# hexdump2wireshark.pl
# -*- mode: Perl -*-
# Extracts hex dumps of packets from Radiator Trace 5 log
# and writes them to an output file compatible 
# to be imported into Wireshark or converted to pcap file 
# with text2pcap.
#
# Usage:
#
# perl hexdump2wireshark.pl < /var/log/radius/logfile > hexdumps-from-radiator-log.txt
# text2pcap -i 17 -u 1812,1812 hexdumps-from-radiator-log.txt hexdumps-from-radiator-log.pcap
#
# Author: Tuure Vartiainen (vartiait@open.com.au)
# Copyright (C) 2016 Open System Consultants
# $Id$

use strict;
use warnings;

my $counter = 0;
my ($line, $line_length, $hex);
my ($my_ip, $dir, $ip, $port, $req, $auth_port, $acct_port);
$my_ip = "127.0.0.1";
$auth_port = 1812;
$acct_port = 1813;
my $start = 0;

while (<>) {
    #print "\n" if $counter == 0;

    $line = $_;

    if ($line =~ /^\*\*\* \S+ (\S+) (\S+) port (\d+) \.\.\.\./i) {
        $dir = $1;
        $ip = $2;
        $port = $3;
        $dir = ($dir =~ /from/i) ? 0 : 1;
        my $port2 = ($req) ? $acct_port : $auth_port;
        if ($dir) {
            print "##TEXT2PCAP -i 17 -4 $my_ip,$ip -u $port2,$port\n";
        }
        else {
            print "##TEXT2PCAP -i 17 -4 $ip,$my_ip -u $port,$port2\n";
        }
    }
    elsif ($line =~ /^Packet length =/i) {
        $start = 1;
        next;
    } 
    elsif ($line =~ /^Code:\s+(\S+)/i) {
        $req = $1;
        $req = ($req =~ /Accounting-Request/i) ? 1 : 0;
        $counter = 0;
        $start = 0;
        print "\n";
        next;
    }
    elsif ($line =~ /Creating (\S+) port (\S+)/i) {
        my $type = $1;
        my $addr = $2;
        my ($t_ip, $t_port) = $addr =~ /(\S+):(\d+)$/i;
        print "$t_ip $t_port\n";
        if ($type =~ /authentication/i) {
            $auth_port = $t_port;
        }
        elsif ($type =~ /accounting/i) {
            $acct_port = $t_port;
        }
        $my_ip = $t_ip;
    }

    next unless $start != 0;

    $line =~ s/\s+//g;
    $line =~ s/\n//g;

    $line_length = length($line);
    $hex = sprintf("%04x", $counter);

    if ($line ne "") {
        #print "[$line]";
        print "$hex $_";
        $counter = $counter + ($line_length / 2);
    }
    else {
        #print "\n";
        $counter = 0;
    }
}

