#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Dense::Square;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day8';
$file = "inputs/day8-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;
my @grid = ();
my $width;
my $height = 0;
while (<$fh>) {
    chomp;
    my @line = split //;
    $width = scalar @line if !defined $width;
    push @grid, @line;
    $height++;
}

my $g = Advent::Grid::Dense::Square->new({
    grid => \@grid,
    width => $width,
});

my $score = 0;

for my $y (1..$height - 2) {
    for my $x (1..$width - 2) {
        my $i = $y * $width + $x;
        my $v = $g->get_at_index($i);
        my $s = scenic_score($x, $y, $v);
        $score = $s if $s > $score;
    }
}

say $score;

sub scenic_score {
    my ($x, $y, $v) = @_;

    my $t = 0;
    for (my $i = $y - 1; $i >= 0; $i--) {
        my $n = $g->get_at_index($i * $width + $x);
        $t++;
        last if ($n >= $v);
    }
    my $r = 0;
    for ($x + 1..$width - 1) {
        my $n = $g->get_at_index($y * $width + $_);
        $r++;
        last if ($n >= $v);
    }
    my $b = 0;
    for ($y + 1..$height - 1) {
        my $n = $g->get_at_index($_ * $width + $x);
        $b++;
        last if ($n >= $v);
    }
    my $l = 0;
    for (my $i = ($x - 1); $i >= 0; $i--) {
        my $n = $g->get_at_index($y * $width + $i);
        $l++;
        last if ($n >= $v);
    }
    
    return $t * $r * $l * $b;
}

