#!/usr/bin/env perl
use Mojo::Base -strict;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day14';
$file = "inputs/day14-$file" if $file =~ /test/;

my $paths = [];
my ($minx, $miny, $maxx, $maxy) = (0xffff, 0xffff, 0, 0);
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my @coords = split ' -> ', $_;
    my @path = map { [ split ',', $_ ] } @coords;
    push @$paths, \@path;

    my $mx = min map { $_->[0] } @path;
    $minx = $mx if $mx < $minx;
    my $my = min map { $_->[1] } @path;
    $miny = $my if $my < $miny;
    $mx = max map { $_->[0] } @path;
    $maxx = $mx if $mx > $maxx;
    $my = max map { $_->[1] } @path;
    $maxy = $my if $my > $maxy;
}

my $start = [500, 0];
my $rocks = {};
my $sand = {};

for my $path (@$paths) {
    for (my $i = 0; $i < scalar @$path - 1; $i++) {
        my $p = $path->[$i];
        my $n = $path->[$i+1];

        if ($p->[0] == $n->[0]) {
            my $ma = max($p->[1], $n->[1]);
            my $mi = min($p->[1], $n->[1]);
            for my $y ($mi..$ma) {
                $rocks->{$p->[0], $y} = 1;
            }
        } else {
            my $ma = max($p->[0], $n->[0]);
            my $mi = min($p->[0], $n->[0]);
            for my $x ($mi..$ma) {
                $rocks->{$x, $p->[1]} = 1;
            }
        }
    }
}

my $units = 0;
my $pos = $start;
while (1) {
    my $newpos = step($pos);

    if (same_pos($pos, $newpos)) {
        $pos = $start;
        $units++;
    } elsif (in_abyss($newpos)) {
        last;
    } else {
        $pos = $newpos;
    }
}

say $units;

sub step {
    my $pos = shift;
    my $dx = $pos->[0];
    my $dy = $pos->[1] + 1;
    for (([$dx, $dy], [$dx - 1, $dy], [$dx + 1, $dy])) {
        return $_ if !is_blocked($_);
    }
    $sand->{$pos->[0], $pos->[1]} = 1;
    return $pos;
}

sub is_blocked {
    my $p = shift;
    my $x = $p->[0];
    my $y = $p->[1];
    return exists $rocks->{$x, $y} || exists $sand->{$x, $y};
}

sub same_pos {
    my ($p1, $p2) = @_;
    return $p1->[0] == $p2->[0] && $p1->[1] == $p2->[1];
}

sub in_abyss {
    my $p = shift;
    return $p->[0] < $minx || $p->[0] > $maxx || $p->[1] > $maxy;
}

