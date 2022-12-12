#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Dijkstra;
use Advent::Grid::Dense::Square;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day12';
$file = "inputs/day12-$file" if $file =~ /test/;

my @grid = ();
my $height = 0;
my $width;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my @line = split //;
    $width = scalar @line if !defined $width;
    push @grid, @line;
    $height++;
}

my $start = first_index { $_ eq 'S' } @grid;
my $end   = first_index { $_ eq 'E' } @grid;

$grid[$start] = 'a';
$grid[$end] = 'z';
my @ords = map { ord($_) - ord('a') } @grid;

my $g = Advent::Grid::Dense::Ord->new({
    grid => \@ords,
    width => $width,
});

my $e = $g->edge_list();
my $d = Advent::Dijkstra->new;

say $d->get_shortest_path_length({
    start     => $start,
    end       => $end,
    edge_list => $e
});

package Advent::Grid::Dense::Ord;

use Mojo::Base 'Advent::Grid::Dense::Square';

sub edge_list {
    my $self = shift;
    my $edges = {};
    for (my $i = 0; $i < scalar @{$self->{grid}}; $i++) {
        my $v = $self->get_at_index($i);
        for my $n ($self->neighbours_from_index($i)) {
            my $nv = $self->get_at_index($n);
            $edges->{$i}->{$n} = 1 if $nv <= $v + 1;
        }
    }
    return $edges;
}

