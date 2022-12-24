#!/usr/bin/env perl
use Mojo::Base -strict;

use List::PriorityQueue;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day24';
$file = "inputs/day24-$file" if $file =~ /test/;

my $dirs = {
    '^' => [0, -1],
    'v' => [0, 1],
    '<' => [-1, 0],
    '>' => [1, 0],
};

my $bliz = {};
my ($minx, $maxx, $miny, $maxy) = (1, 0, 1, 0);
my $startx = 0;
my $endx = 0;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    $maxx = (length $_) - 1;
    my $x = 0;
    for my $ch (split //, $_) {
        if ($maxy == 0 && $ch eq '.') {
            $startx = $x;
        }

        if ($maxy > 0 && $ch eq '.') {
            $endx = $x;
        }

        if ($ch =~ /[\^v<>]/) {
            $bliz->{$x, $maxy, $ch} = 1;
        }
        $x++;
    }
    $maxy++;
}

$maxy--;

my @opts = [0, 0];
push @opts, values %$dirs;

my $steps = run_part([$startx, 0], [$endx, $maxy], 0);
my $steps2 = run_part([$endx, $maxy], [$startx, 0], $steps);
my $steps3 = run_part([$startx, 0], [$endx, $maxy], $steps2);
say $steps3;

sub run_part {
    my ($start, $end, $start_time) = @_;

    my ($startx, $starty) = @$start;
    my ($endx, $endy) = @$end;

    my $q = List::PriorityQueue->new();
    my $seen = {};
    my $st = [$startx, $starty, $start_time];

    $q->insert($st, $start_time);
    $seen->{state_key($st)} = 1;

    while (my $c = $q->pop()) {
        my ($x, $y, $t) = @$c;

        if ($x == $endx && $y == $endy) {
            return $t;
        }

        for my $o (@opts) {
            my ($dx, $dy) = @$o;
            my $nx = $x + $dx;
            my $ny = $y + $dy;

            if (can_be_at($nx, $ny, $t + 1)) {
                my $state = [$nx, $ny, $t + 1];
                my $k = state_key($state);
                if (!exists $seen->{$k}) {
                    $q->insert($state, $t + 1);
                    $seen->{$k} = 1;
                }
            }
        }
    }
}

sub can_be_at {
    my ($x, $y, $t) = @_;

    return 1 if $y == 0 && $x == $startx;
    return 1 if $y == $maxy && $x == $endx;

    return 0 if $x < $minx || $y < $miny || $x >= $maxx || $y >= $maxy;

    # TODO: this would be way quicker but doesn't work because I'm
    #       bad at modulo arithmatic
    # for my $d (keys %$dirs) {
    #     my ($dx, $dy) = @{$dirs->{$d}};
    #     my $nx = ($x - $t * $dx) % ($maxx - 1);
    #     my $ny = ($y - $t * $dy) % ($maxy - 1);
    #     if (exists $bliz->{$nx, $ny, $d}) {
    #         return 0;
    #     }
    # }

    for my $b (keys %$bliz) {
        my ($bx, $by, $bd) = split $;, $b;
        my ($dx, $dy) = @{$dirs->{$bd}};
        if ($x == ($bx + $t * $dx) % ($maxx - 1) &&
            $y == ($by + $t * $dy) % ($maxy - 1)) {
            return 0;
        }
    }

    return 1;
}

sub state_key {
    my $state = shift;
    return join '', @$state;
}

