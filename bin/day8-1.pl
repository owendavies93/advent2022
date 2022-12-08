#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Dense::Square;

use List::AllUtils qw(:all);

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

my $visible_count = (2 * ($width - 1)) + (2 * ($height - 1));

for my $y (1..$height - 2) {
    for my $x (1..$width - 2) {
        my $i = $y * $width + $x;
        my $v = $g->get_at_index($i);
        $visible_count++ if is_visible($x, $y, $v);
    }
}

say $visible_count;

sub is_visible {
    my ($x, $y, $v) = @_;

    # top
    return 1 if all { $_ < $v } get_from_y_range(0, $y - 1, $x);
    # right
    return 1 if all { $_ < $v } get_from_x_range($x + 1, $width - 1, $y);
    # bottom
    return 1 if all { $_ < $v } get_from_y_range($y + 1, $height - 1, $x);
    # left
    return 1 if all { $_ < $v } get_from_x_range(0, $x - 1, $y);
    
    return 0;
}

sub get_from_x_range {
    my ($start, $end, $y) = @_;
    return map { $g->get_at_index($y * $width + $_) } ($start..$end);
}

sub get_from_y_range {
    my ($start, $end, $x) = @_;
    return map { $g->get_at_index($_ * $width + $x) } ($start..$end);
}
