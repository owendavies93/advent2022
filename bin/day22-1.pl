#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Dense::Square;
use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my @DIRS = qw(N E S W);

my $rot = {
    R => sub {
        my $dir = shift;
        my $i = first_index { $_ eq $dir } @DIRS;
        return $DIRS[($i + 1) % @DIRS];
    },
    L => sub {
        my $dir = shift;
        my $i = first_index { $_ eq $dir } @DIRS;
        return $DIRS[($i - 1) % @DIRS];
    }
};

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day22';
$file = "inputs/day22-$file" if $file =~ /test/;

my $temp_grid;
my $width = 0;
my $height = 0;
my $grid_done = 0;
my @insts;
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    
    if (!$_) {
        $grid_done = 1;
    }

    if ($grid_done) {
        my @numbers = get_ints($_);
        my @letters = $_ =~ /([RL])/g;
        @insts = zip @numbers, @letters;
    } else {
        $temp_grid .= ($_ . "\n");
        $width = length $_ if $width < length $_;
        $height++;
    }
}

my $move_index = {
    N => $width * -1,
    E => 1,
    S => $width,
    W => -1,
};

my @split = split /\n/, $temp_grid;
my @grid;
for my $line (@split) {
    if (length $line < $width) {
        $line .= ' ' x ($width - length $line);
    }
    push @grid, split //, $line;
}

my $g = Advent::Grid::Dense::Square->new({
    grid  => \@grid,
    width => $width,
});

my $dir = 'E';
my $x = first_index { $_ eq '.' } @grid;
my $y = 0;

for my $inst (@insts) {
    last if !defined $inst;
    
    if ($inst =~ /[RL]/) {
        # rotate
        $dir = $rot->{$inst}->($dir);
    } else {
        # move
        while ($inst > 0) {
            my $i  = $y * $width + $x;

            my $ni = next_from_index($i, $dir);
            last if !defined $ni;

            if ($dir =~ /[NS]/) { # x is fixed
                $y = ($ni - $x) / $width;
            } else { # y is fixed
                $x = $ni - ($y * $width);
            }
            
            $inst--;
        }
    }
}

my $facing_score = first_index { $_ eq $dir } @DIRS;
$facing_score = ($facing_score - 1) % @DIRS;
my $password = (1000 * ($y + 1)) + (4 * ($x + 1)) + $facing_score;
say $password;

sub next_from_index {
    my ($i, $dir) = @_;

    # in the same order as @DIRS
    my @adj = ($i - $width, $i + 1, $i + $width, $i - 1);

    my $dir_idx = first_index { $_ eq $dir } @DIRS;
    my $idx = $adj[$dir_idx];
    my $v = $g->get_at_index($idx);
    
    if (!defined $v) {
        ($idx, $v) = wrap($idx, $dir);
    }

    return if $v eq '#'; # omit if wall
    
    return $idx if $v eq '.'; # add as normal if space

    ($idx, $v) = wrap($idx, $dir); 

    return if $v eq '#'; # we're still at a wall

    return $idx;
}

sub wrap {
    my ($idx, $dir) = @_;

    # move in the opposite direction until we hit more air or the edge
    my $delta = $move_index->{$dir} * -1;

    $idx += $delta;
    my $v = $g->get_at_index($idx);
    do {
        $idx += $delta;
        $v = $g->get_at_index($idx);
    } while (defined $v && $v ne ' ');

    # get back to the grid
    $idx -= $delta;
    return ($idx, $g->get_at_index($idx));
}
