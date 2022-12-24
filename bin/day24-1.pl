#!/usr/bin/env perl
use Mojo::Base -strict;

use Data::Dumper;
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
my ($minx, $maxx, $miny, $maxy) = (0, 0, 0, 0);
my $startx = 0;
my $endx = 0;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    $maxx = (length $_) - 3;
    my $x = -1;
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

$maxy -= 3;

my $starty = $miny - 1;
my $endy = $maxy + 1;

my @opts = [0, 0];
push @opts, values %$dirs;

my $q = List::PriorityQueue->new();
my $seen = {};
my $start = [$startx, $starty, 0];

$q->insert($start, 0);
$seen->{state_key($start)} = 1;

my $best_t = 0;

while (my $c = $q->pop()) {
    my ($x, $y, $t) = @$c;

    if ($x == $endx && $y == $endy) {
        say scalar keys %$seen;
        say $t;
        exit;
    }

    for my $o (@opts) {
        my ($dx, $dy) = @$o;
        my $nx = $x + $dx;
        my $ny = $y + $dy;

        # say "trying ($nx, $ny)";

        if (can_be_at($nx, $ny, $t + 1)) {
            say "can go to ($nx, $ny) at " . ($t + 1);
            my $state = [$nx, $ny, $t + 1];
            my $k = state_key($state);
            if (!exists $seen->{$k}) {
                $q->insert($state, $t + 1);
                $seen->{$k} = 1;
            }
        }
    }
}

sub can_be_at {
    my ($x, $y, $t) = @_;

    return 1 if $y == $starty && $x == $startx;
    return 1 if $y == $endy && $x == $endx;

    return 0 if $x < $minx || $y < $miny || $x > $maxx || $y > $maxy;

    for my $d (keys %$dirs) {
        my ($dx, $dy) = @{$dirs->{$d}};
        my $nx = wrap($x, $t, $dx, $maxx);
        my $ny = wrap($y, $t, $dy, $maxy);
        if (exists $bliz->{$nx, $ny, $d}) {
            return 0;
        }
    }

    return 1;
}
    
sub wrap {
    my ($a, $t, $d, $max) = @_;

    my $sub = $t * $d;
    my $res = $a - $sub;

    while ($res < 0) {
        $res += $max + 1;
    }
    return $res;
}

sub state_key {
    my $state = shift;
    return join '', @$state;
}

