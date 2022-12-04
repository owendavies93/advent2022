#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day4';
$file = "inputs/day4-$file" if $file =~ /test/;

my $total = 0;
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my ($lmin, $lmax, $rmin, $rmax) = $_ =~ /(\d+)-(\d+),(\d+)-(\d+)/;
    if ($lmin >= $rmin && $lmax <= $rmax || $rmin >= $lmin && $rmax <= $lmax) {
        $total++;
    }
}

say $total;
