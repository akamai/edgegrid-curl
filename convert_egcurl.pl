#!/usr/bin/perl

use strict;
use warnings;

while (<STDIN>) {
    if ($_ =~ /^\s*($|#|;)/o || $_ =~ /^\s*\[(.+?)\]\s*$/) {
        print($_);
        next;
    }
    chomp($_);
    $_ =~ s/secret/client_secret/go;
    $_ =~ s/:/ = /go;
    my @options = split(/ +/, $_);
    @options = sort(@options);
    foreach my $thing (@options) {
        print($thing . "\n");
    }
}
