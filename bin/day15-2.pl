#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day15';
$file = "inputs/day15-$file" if $file =~ /test/;

my $fourM = 4000000;
my $max_index = $file =~ /test/ ? 20 : $fourM;
my $sensors = {};

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my ($sx, $sy, $bx, $by) = get_ints($_, 1);
    my $d = distance($sx, $sy, $bx, $by);
    $sensors->{$sx, $sy} = $d;
}

# TODO: can we shrink this range?
for my $y (0..$max_index) {
    my @ranges = ();
    while (my ($s, $d) = each %$sensors) {
        my ($sx, $sy) = split $;, $s;
        my ($min, $max, $u, $l) = get_bounds($sx, $sy, $y, $d);
        if ($l >= 0 && $u <= $max_index) {
            push @ranges, [max(0, $u), min($max_index, $l)];
        }
    }

    @ranges = sort {
        $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1]
    } @ranges;

    my $max = 0;
    for my $r (@ranges) {
        my ($l, $u) = @$r;
        # Only need to check that it's out of the range here
        # otherwise you could move the beacon closer to the sensor and
        # it would no longer be unique
        if ($l > $max) {
            say (($max + 1) * $fourM + $y);
            exit;
        }
        $max = max($max, $u);
    }
}

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
