#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day18';
$file = "inputs/day18-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $cubes = {};
while (<$fh>) {
    chomp;
    my ($x, $y, $z) = get_ints($_);
    $cubes->{$x,$y,$z} = 1;
}

my $surface_area = 0;
for my $c (keys %$cubes) {
    my $adj = get_adjacent_faces($c);
    $surface_area += (6 - $adj);
}

say $surface_area;

sub get_adjacent_faces {
    my $c = shift;
    my ($x, $y, $z) = split $;, $c;

    my @adj = (
        [1, 0, 0], [-1, 0, 0],
        [0, 1, 0], [0, -1, 0],
        [0, 0, 1], [0, 0, -1],
    );

    my $adj_count = 0;
    for my $a (@adj) {
        my ($dx, $dy, $dz) = @$a;
        if (exists $cubes->{$x+$dx, $y+$dy, $z+$dz}) {
            $adj_count++;
        }
    }

    return $adj_count;
}
