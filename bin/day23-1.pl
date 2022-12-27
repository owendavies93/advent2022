#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Point::Point2;
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
        my $p = Advent::Point::Point2->new($x, $height);
        $elves->set($p, 1) if $ch eq '#';
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
        my $p = Advent::Point::Point2->new($x, $y);

        next if all { !defined $_ } $elves->neighbour_values($p);

        for my $dir (@DIRS) {
            my ($dx, $dy) = @{$dir->[0]};
            my $empty = 1;

            for my $check (@$dir) {
                my ($ddx, $ddy) = @$check;
                my $pdd = Advent::Point::Point2->new($ddx, $ddy);
                if (defined $elves->get($p->add($pdd))) {
                    $empty = 0;
                    last;
                }
            }

            if ($empty == 1) {
                my $pd = $p->add(Advent::Point::Point2->new($dx, $dy));
                $to_move->{$p->key} = $pd;
                push @{$dests->{$pd->key}}, $p;
                last;
            }
        }
    }

    for my $dest (keys %$dests) {
        my @prevs = @{$dests->{$dest}};
        if (scalar @prevs > 1) {
            delete $to_move->{$_->key} for @prevs;
        }
    }

    for my $tm (keys %$to_move) {
        my ($fromx, $fromy) = split $;, $tm;
        my $from = Advent::Point::Point2->new($fromx, $fromy);
        my $to = $to_move->{$tm};

        $elves->delete($from);
        $elves->set($to, 1);
    }

    my $d = shift @DIRS;
    push @DIRS, $d;
}

my $minx = my $miny = 0xffff;
my $maxx = my $maxy = 0;

for my $elf ($elves->all()) {
    my ($x, $y) = split $;, $elf;
    my $p = Advent::Point::Point2->new($x, $y);
    $minx = $p->x if $p->x < $minx;
    $maxx = $p->x if $p->x > $maxx;
    $miny = $p->y if $p->y < $miny;
    $maxy = $p->y if $p->y > $maxy;
}

my $empty = 0;
for my $y ($miny..$maxy) {
    for my $x ($minx..$maxx) {
        my $p = Advent::Point::Point2->new($x, $y);
        $empty++ if !defined $elves->get($p);
    }
}

say $empty;

