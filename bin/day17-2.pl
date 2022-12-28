#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Dense::Square;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day17';
$file = "inputs/day17-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;
my $jets = scalar(<$fh>);
chomp($jets);
my @jets = split //, $jets;

my @grid = ();
my $width = 7;
my $g = Advent::Grid::Dense::Shapes->new({
    grid => \@grid,
    width => $width,
});

my @types = (
    [[0,0], [1,0], [2,0], [3,0]],
    [[0,1], [1,0], [1,1], [1,2], [2,1]],
    [[0,0], [1,0], [2,0], [2,1], [2,2]],
    [[0,0], [0,1], [0,2], [0,3]],
    [[0,0], [0,1], [1,0], [1,1]],
);

my $num_types = scalar @types;
my $curr_type = 0;
my $curr_jet = 0;
my $total = 2022;
my $starty = -1;
my $states = {};
my $to_add = 0;

for my $i (0..$total - 1) {
    my ($x, $y) = (2, $starty + 4); 

    $g->add_type($x, $y, $curr_type); 

    while (1) {
        $g->remove_type($x, $y, $curr_type);
        my $shift = get_dir($jets[$curr_jet]);
        $x += $shift;
        $curr_jet++;
        $curr_jet = 0 if $curr_jet == scalar @jets;

        if ($g->collides($x, $y, $curr_type)) {
            $x -= $shift;
        }

        $y--;

        if ($g->collides($x, $y, $curr_type)) {
            $y++;
            $g->add_type($x, $y, $curr_type);

            if ($file =~ /test/ && $i == 26) {
                $to_add = $starty;
            } elsif ($i == 1684) {
                $to_add = $starty - 2;
            }

            my @topn = $g->top_n_rows(10, $starty);
            my $state_key = join $;, ($curr_type, $curr_jet, @topn);
            if (exists $states->{$state_key}) {
                my ($lasty, $lasti) = @{$states->{$state_key}};
                my $period = $i - $lasti;
                my $top_diff = $starty - $lasty;
                my $to_go = 1000000000000 - $i;
                my $rem_cycles = int($to_go / $period);
                my $top_increase = $rem_cycles * $top_diff;
                my $rocks_after_amp = $i + $period * $rem_cycles;
                my $top_after_amp = $starty + $top_increase;
                say $top_after_amp + $to_add;
                exit;
            } else {
                $states->{$state_key} = [$starty, $i];
            }
            last;
        }

        $g->add_type($x, $y, $curr_type);
    }

    $starty = get_new_start($starty, $y, $curr_type);

    $curr_type++;
    $curr_type = 0 if $curr_type == scalar @types;
}

sub get_dir {
    my $dir = shift;
    return $dir eq '<' ? -1 : 1;
}

sub get_new_start {
    my ($oldstart, $y, $type_index) = @_;
    my $rock = $types[$type_index];
    my $starty = 0;
    for my $c (@$rock) {
        my ($dx, $dy) = @$c;
        $starty = max($starty, $y + $dy);
    }
    return max($starty, $oldstart);
}

package Advent::Grid::Dense::Shapes;

use Mojo::Base 'Advent::Grid::Dense';

sub add_type {
    my ($self, $x, $y, $type_index) = @_;
    $self->_change_type($x, $y, $type_index, 1);
}

sub collides {
    my ($self, $x, $y, $type_index) = @_;
    my $rock = $types[$type_index];
    for my $c (@$rock) {
        my ($dx, $dy) = @$c;
        my ($nx, $ny) = ($x + $dx, $y + $dy);
        if ($nx >= $self->{width} || $nx < 0 || $ny < 0) {
            return 1;
        }
        my $i = $ny * $self->{width} + $nx;
        return 1 if $self->get_at_index($i);
    }
    return 0;
}

sub remove_type {
    my ($self, $x, $y, $type_index) = @_;
    $self->_change_type($x, $y, $type_index, 0);
}

sub top_n_rows {
    my ($self, $n, $starty) = @_;
    my $y = $starty;
    my @arr = ();
    while ($y > $starty - $n) {
        for my $x (0..$self->{width} - 1) {
            my $i = $y * $self->{width} + $x;
            push @arr, $self->get_at_index($i) // 0;
        }
        $y--;
    }
    return @arr;
}

sub _change_type {
    my ($self, $x, $y, $type_index, $on) = @_;
    my $rock = $types[$type_index];
    for my $c (@$rock) {
        my ($dx, $dy) = @$c;
        my ($nx, $ny) = ($x + $dx, $y + $dy);
        my $i = $ny * $self->{width} + $nx;
        $self->set_at_index($i, $on);
    }
}
