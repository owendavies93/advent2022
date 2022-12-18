#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day18';
$file = "inputs/day18-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $cubes = {};
my $minx = my $miny = my $minz = 0xffff;
my $maxx = my $maxy = my $maxz = 0;
while (<$fh>) {
    chomp;
    my ($x, $y, $z) = get_ints($_);
    $cubes->{$x,$y,$z} = 1;

    $minx = $x if $x < $minx;
    $maxx = $x if $x > $maxx;
    $miny = $y if $y < $miny;
    $maxy = $y if $y > $maxy;
    $minz = $z if $z < $minz;
    $maxz = $z if $z > $maxz;
}

$minx--; $miny--; $minz--;
$maxx++; $maxy++; $maxz++;

my @adj_list = (
    [1, 0, 0], [-1, 0, 0],
    [0, 1, 0], [0, -1, 0],
    [0, 0, 1], [0, 0, -1],
);

my @q = ([$minx, $miny, $minz]);
my $seen = {};
while (scalar @q > 0) {
    my $c = shift @q;
    my ($x, $y, $z) = @$c;

    next if exists $seen->{$x, $y, $z};
    $seen->{$x, $y, $z} = 1;

    for my $a (@adj_list) {
        my ($dx, $dy, $dz) = @$a;
        my $nx = $x + $dx;
        my $ny = $y + $dy;
        my $nz = $z + $dz;

        if ($minx <= $nx && $nx <= $maxx &&
            $miny <= $ny && $ny <= $maxy &&
            $minz <= $nz && $nz <= $maxz &&
            !exists $cubes->{$nx, $ny, $nz}) {
            push @q, [$nx, $ny, $nz];
        }
    }
}

my $unseen = {};
for my $x ($minx..$maxx) {
    for my $y ($miny..$maxy) {
        for my $z ($minz..$maxz) {
            $unseen->{$x, $y, $z} = 1 if !exists $seen->{$x, $y, $z};
        }
    }
}

my $surface_area = 0;
for my $c (keys %$unseen) {
    my ($x, $y, $z) = split $;, $c;
    for my $a (@adj_list) {
        my ($dx, $dy, $dz) = @$a;
        if (!exists $unseen->{$x+$dx, $y+$dy, $z+$dz}) {
            $surface_area++;
        }
    }
}

say $surface_area;
