#!/usr/bin/env perl
use Mojo::Base -strict;

use lib '../cheatsheet/lib';

use Advent::Utils::Input qw(get_lines);

use List::PriorityQueue;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day24';
$file = "inputs/day24-$file" if $file =~ /test/;

my $dirs = {
    '>' => [0, 1],
    '<' => [0, -1],
    '^' => [-1, 0],
    'v' => [1, 0],
};

my $bliz = {};

open(my $fh, '<', $file) or die $!;
my @data = get_lines($fh);

for my $i (0..scalar @data - 1) {
    my @line = split //, $data[$i];
    for my $j (1..scalar @line) {
        last if $line[$j] eq '#';
        next if $line[$j] eq '.';
        $bliz->{$i - 1, $j - 1, $line[$j]} = 1;
    }
}

my $len_x = scalar @data - 2;
my $len_y = (length $data[0]) - 2;
my @opts = ([0, 0]);
push @opts, values %$dirs;

my ($sx, $sy) = (-1, 0);
my ($ex, $ey) = ($len_x, $len_y - 1);

my $heur = abs($ex - $sx) + abs($ey - $sy);
my $q = List::PriorityQueue->new();
my $state = [$heur, $sx, $sy, 0];
$q->insert($state, $heur);
my $seen = {
    state_key($state) => 1,
};

while (my $c = $q->pop()) {
    my ($score, $x, $y, $t) = @$c;
    for my $o (@opts) {
        my ($dx, $dy) = @$o;
        my $nx = $x + $dx;
        my $ny = $y + $dy;
        if ($nx == $ex && $ny == $ey) {
            say $t + 1;
            exit;
        }

        if (!collides($t + 1, $nx, $ny)) {
            my $h = abs($x - $ex) + abs($y - $ey) + $t;
            my $newitem = [$h, $nx, $ny, $t + 1];
            my $k = state_key($newitem);
            if (!exists $seen->{$k}) {
                $q->insert($newitem, $h);
                $seen->{$k} = 1;
            }
        }
    }
}

sub collides {
    my ($time, $x, $y) = @_;

    return 0 if $x == $sx && $y == $sy;
    return 0 if $x == $ex && $y == $ey;
    return 1 if $x <= -1 || $y <= -1 || $x >= $len_x || $y >= $len_y;

    for my $d (keys %$dirs) {
        my ($dx, $dy) = @{$dirs->{$d}};
        my $nx = ($x - $time * $dx) % $len_x;
        my $ny = ($y - $time * $dy) % $len_y;
        return 1 if exists $bliz->{$nx, $ny, $d};
    }

    return 0;
}

sub state_key {
    my $state = shift;
    return join '', @$state;
}

