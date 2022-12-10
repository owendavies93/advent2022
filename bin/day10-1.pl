#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);
use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day10';
$file = "inputs/day10-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $c = 1;
my $r = 1;
my $sum = 0;

my @cycles = (20, 60, 100, 140, 180, 220);

while (<$fh>) {
    chomp;
    check_cycles($c);
    if ($_ =~ /addx/) {
        $c++;
        check_cycles($c);
        my ($v) = get_ints($_, 1);
        $r += $v;
    }

    $c++;
}

say $sum;

sub check_cycles {
    my $c = shift;
    if (any { $_ == $c } @cycles) {
        $sum += ($c * $r);
    }
}
