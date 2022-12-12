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

my $g = Advent::Grid::Dense::Ord->new({
    grid => \@grid,
    width => $width,
    });

my $e = $g->edge_list(1);
my $d = Advent::Dijkstra->new;
my $start = first_index { $_ eq 'S' } @grid;
my $end = first_index { $_ eq 'E' } @grid;
$e->{$end} = {};

my @starts = indexes { $_ eq 'a' } @grid;
push @starts, $start;

say min map {
    my $p = $d->get_shortest_path_length({
        start => $_,
        end => $end,
        edge_list => $e,
        regen => 1,
    });
    $p;
} @starts;

package Advent::Grid::Dense::Ord;

use Mojo::Base 'Advent::Grid::Dense';

sub neighbours_from_index {
    my ($self, $i) = @_;

    my @adjacent;   
    if ($i % $self->{width} == 0) {
        @adjacent = ($i + 1, $i + $self->{width}, $i - $self->{width});
    } elsif ($i % $self->{width} == ($self->{width} - 1)) {
        @adjacent = ($i - 1, $i + $self->{width}, $i - $self->{width});
    } else {
        @adjacent = ($i + 1, $i - 1, $i + $self->{width}, $i - $self->{width});
    }
    @adjacent = grep { $self->check_bounds_of_index($_) } @adjacent;
    return grep {
        ($self->get_at_index($i) eq 'z' && $self->get_at_index($_) eq 'E') ||
        ($self->get_at_index($i) eq 'S' && $self->get_at_index($_) eq 'a') ||
        (
            ord($self->get_at_index($_)) <= ord($self->get_at_index($i)) + 1 &&
            $self->get_at_index($_) ne 'E'
        )
    } @adjacent;
}
