#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day15';
$file = "inputs/day15-$file" if $file =~ /test/;

my $target_row = $file =~ /test/ ? 10 : 2000000;
my $no_b_xs = {};

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my ($sx, $sy, $bx, $by) = get_ints($_, 1);
    my $d = distance($sx, $sy, $bx, $by);
    my ($min, $max, $l, $u) = get_bounds($sx, $sy, $target_row, $d);
    if ($max - $min <= $d) {
        $no_b_xs->{$_} = 1 for ($l..$u - 1);
    }
}

my @nbx = keys %$no_b_xs;
say scalar @nbx;

sub distance {
    my ($ax, $ay, $bx, $by) = @_;
    return abs($ax - $bx) + abs($ay - $by);
}

sub get_bounds {
    my ($x, $y1, $y2, $dist) = @_;
    my ($min, $max) = sort { $a <=> $b } ($y1, $y2);
    my $nd = $dist - ($max - $min);
    my $lb = $x - $nd;
    my $ub = $x + $nd;
    return ($min, $max, $lb, $ub);
}

