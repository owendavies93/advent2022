#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day10';
$file = "inputs/day10-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $c = 1;
my $r = 1;

my @rows = ();
my $width = 40;
my $height = 6;

while (<$fh>) {
    chomp;
    mark($c, $r);
    if ($_ =~ /addx/) {
        $c++;
        mark($c, $r);
        my ($v) = get_ints($_, 1);
        $r += $v;
    }

    $c++;
}

sub mark {
    my ($c, $r) = @_; 
    my $p = ($c % $width - 1);

    if ($r - 1 <= $p && $p <= $r + 1) {
        $rows[$c - 1] = 1;
    } else {
        $rows[$c - 1] = 0;
    }
}

print_screen();

sub print_screen {
    for my $y (0..($height - 1)) {
        for my $x (0..($width - 1)) {
            if ($rows[$y * $width + $x] == 1) {
                print '#';
            } else {
                print '.';
            }
        }
        print "\n";
    }
}

