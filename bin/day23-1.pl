#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Sparse;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day23';
$file = "inputs/day23-$file" if $file =~ /test/;

my @DIRS = (
    # N, NE, NW
    [[0, -1], [1, -1], [-1, -1]],
    # S, SE, SW
    [[0, 1], [1, 1], [-1, 1]],
    # W, NW, SW
    [[-1, 0], [-1, -1], [-1, 1]],
    # E, NE, SE
    [[1, 0], [1, -1], [1, 1]],
);

my $elves = Advent::Grid::Sparse->new;
my $width;
my $height = 0;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    $width = scalar $_ if !defined $width;
    my $x = 0;
    for my $ch (split //, $_) {
        $elves->set($x, $height, 1) if $ch eq '#';
        $x++;
    }
    $height++;
}

my $rounds = 10;

for (1..$rounds) {
    my $to_move = {};
    my $dests = {};
    for my $elf ($elves->all()) {
        my ($x, $y) = split $;, $elf;

        next if all { !defined $_ } $elves->neighbour_values($x, $y);

        for my $dir (@DIRS) {
            my ($dx, $dy) = @{$dir->[0]};
            my $empty = 1;

            for my $check (@$dir) {
                my ($ddx, $ddy) = @$check;
                if (defined $elves->get($x + $ddx, $y + $ddy)) {
                    $empty = 0;
                    last;
                }
            }

            if ($empty == 1) {
                $to_move->{$x, $y} = [$x + $dx, $y + $dy];
                push @{$dests->{$x + $dx, $y + $dy}}, [$x, $y];
                last;
            }
        }
    }

    for my $dest (keys %$dests) {
        my @prevs = @{$dests->{$dest}};
        if (scalar @prevs > 1) {
            delete $to_move->{$_->[0], $_->[1]} for @prevs;
        }
    }

    for my $tm (keys %$to_move) {
        my ($fromx, $fromy) = split $;, $tm;
        my ($tox, $toy) = @{$to_move->{$tm}};
        $elves->delete($fromx, $fromy);
        $elves->set($tox, $toy, 1);
    }

    my $d = shift @DIRS;
    push @DIRS, $d;
}

my $minx = my $miny = 0xffff;
my $maxx = my $maxy = 0;

for my $elf ($elves->all()) {
    my ($x, $y) = split $;, $elf;
    $minx = $x if $x < $minx;
    $maxx = $x if $x > $maxx;
    $miny = $y if $y < $miny;
    $maxy = $y if $y > $maxy;
}

my $empty = 0;
for my $y ($miny..$maxy) {
    for my $x ($minx..$maxx) {
        $empty++ if !defined $elves->get($x, $y);
    }
}

say $empty;

